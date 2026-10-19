import * as Sentry from '@sentry/node'
import { z } from 'zod'
import { config } from '~/system/config'
import { createLogger } from '~/system/logger'

const log = createLogger('gemini')

// The model every scan goes to. Not gemini-2.5-flash any more: Google stopped
// serving it to API keys created after 2026-10-19, and the failure is a 404 on
// the model path, not a deprecation warning — the next retirement will land the
// same way, which is why the name is one constant. Flash-Lite is priced the same
// as 2.5 Flash was ($0.30 / $2.50 per million tokens), answers in seconds rather
// than tens of seconds and spends no thinking tokens, with the same vision input
// and structured JSON output the scan relies on.
const GEMINI_MODEL = 'gemini-3.5-flash-lite'

const GEMINI_API_URL = `https://generativelanguage.googleapis.com/v1beta/models/${GEMINI_MODEL}:generateContent`

// What a caller sees of a failed call. The cause goes to the log and the
// reporter and no further: the fetch error quotes the request URL and the
// model's answer, and Apollo relays an uncaught resolver error's message to
// the client as is.
export const GEMINI_FAILED = 'The model did not answer'

type GeminiResponse = { candidates?: { content: { parts: { text?: string }[] } }[] }

const itemSchema = z.object({
  name: z.string().min(1),
  category: z
    .enum([
      'tools',
      'appliances',
      'decor',
      'clothing',
      'documents',
      'food',
      'electronics',
      'furniture',
      'kitchenware',
      'linen',
      'sports',
      'toys',
      'books',
      'media',
      'hygiene',
      'other',
    ])
    .nullable()
    .optional(),
  description: z.string().optional().default(''),
  tags: z.array(z.string()).optional().default([]),
  quantity: z.number().int().positive().optional().default(1),
})

const responseSchema = z.object({
  items: z.array(itemSchema),
})

const cleanGeminiJson = (raw: string) =>
  raw
    .replace(/,\s*]/g, ']')
    .replace(/,\s*}/g, '}')
    .replace(/"([^"]*?)"\s+ou\s+[^,}\]]+/g, '"$1"')
    .replace(/(\d+)\s+ou\s+\d+/g, '$1')

const parseGeminiJson = (text: string) => {
  try {
    return JSON.parse(text) as Record<string, unknown>
  } catch {
    const withoutFences = text.replace(/```(?:json)?\s*([\s\S]*?)```/g, '$1')
    const jsonMatch = withoutFences.match(/\{[\s\S]*\}/)
    if (!jsonMatch) throw new Error(`Gemini did not return valid JSON: ${text.slice(0, 200)}`)
    try {
      return JSON.parse(jsonMatch[0]) as Record<string, unknown>
    } catch {
      try {
        return JSON.parse(cleanGeminiJson(jsonMatch[0])) as Record<string, unknown>
      } catch {
        throw new Error(`Gemini returned unparseable JSON: ${jsonMatch[0].slice(0, 300)}`)
      }
    }
  }
}

const PROMPT = `Analyse cette photo et identifie les objets domestiques qui sont le sujet principal de la prise de vue.

Concentre-toi uniquement sur les objets clairement visibles au centre du cadre, nets et au premier plan.
Ignore les objets en arriere-plan, flous, partiellement coupes par le bord de l'image, ou en peripherie.
En cas de doute sur un objet, ne l'inclus pas.

N'inventorie jamais le meuble ni le contenant qui porte les objets : tiroir, etagere, placard,
armoire, commode, buffet, casier, boite de rangement sont des lieux de rangement, pas des objets.
Un meuble qui ne range rien (canape, table, lampe, chaise) reste un objet valide.

Regroupe en une seule entree les exemplaires du meme type, meme si leurs etiquettes different :
douze pots d'epices etiquetes donnent une entree "Pot d'epices" avec quantity 12, jamais douze entrees.

Pour chaque objet retenu, extrais :
- name : nom de l'objet en francais
- category : une parmi tools, appliances, decor, clothing, documents, food, electronics, furniture, kitchenware, linen, sports, toys, books, media, hygiene, other
- description : breve description en francais (1-2 phrases)
- tags : les mots-cles qui permettront de retrouver l'objet, dans cet ordre :
  1. TOUS les textes lisibles sur l'objet, sans exception : etiquette, marque, parfum, variante,
     taille, contenance, mention manuscrite. N'en omets aucun, n'en resume aucun, ne choisis pas
     les plus interessants — s'il y a quinze etiquettes lisibles, les quinze sont dans la liste.
     Recopie chaque texte tel qu'il est ecrit, meme s'il fait plusieurs mots.
     Quand tu regroupes des exemplaires identiques, la liste porte le texte de chacun d'eux.
  2. ensuite, quelques mots qui decrivent l'objet lui-meme : nature generique, matiere, couleur,
     usage. Un ou deux mots chacun, jamais la simple reprise de name.
  La liste n'a pas de longueur maximale.
  Exemple pour les douze pots : ["cumin", "paprika", "curry", "thym", "origan", "laurier",
  "epice", "condiment", "cuisine"]
- quantity : nombre d'exemplaires du meme type visibles (defaut 1)

Si aucun objet ne satisfait ces criteres, reponds avec une liste vide.
Reponds en JSON avec le schema : { "items": [{ "name", "category", "description", "tags", "quantity" }] }`

export const analyzeImage = async (imageBase64: string) => {
  const { googleApiKey } = config()

  let response: GeminiResponse
  try {
    response = await $fetch<GeminiResponse>(GEMINI_API_URL, {
      method: 'POST',
      // The key travels in a header, never in the URL: a failed call's error
      // message quotes the URL, and that message gets logged and reported.
      headers: { 'content-type': 'application/json', 'x-goog-api-key': googleApiKey },
      body: {
        contents: [
          {
            parts: [
              { text: PROMPT },
              {
                inline_data: {
                  mime_type: 'image/jpeg',
                  data: imageBase64,
                },
              },
            ],
          },
        ],
        generationConfig: {
          responseMimeType: 'application/json',
        },
      },
    })
  } catch (error) {
    // Apollo answers 200 on a resolver error, so Nitro's `error` hook — where
    // the Sentry plugin listens — never fires for this one: report it here.
    log.error('Gemini call failed', error)
    Sentry.captureException(error)
    throw new Error(GEMINI_FAILED)
  }

  const text = response.candidates?.[0]?.content?.parts?.find((part) => part.text)?.text
  if (!text) throw new Error('Gemini did not return any text')

  log.info('Gemini raw response', text)

  const parsed = parseGeminiJson(text)
  const validated = responseSchema.parse(parsed)
  return validated.items
}
