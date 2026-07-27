import { z } from 'zod'
import { config } from '~/system/config/index'
import { createLogger } from '~/system/logger'

const log = createLogger('gemini')

const GEMINI_API_URL =
  'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent'

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
  2. ensuite, quelques mots en minuscules qui decrivent l'objet lui-meme : nature generique,
     matiere, couleur, usage. Un ou deux mots chacun, jamais la simple reprise de name.
  La liste n'a pas de longueur maximale.
  Exemple pour les douze pots : ["cumin", "paprika", "curry", "thym", "origan", "laurier",
  "epice", "condiment", "cuisine"]
- quantity : nombre d'exemplaires du meme type visibles (defaut 1)

Si aucun objet ne satisfait ces criteres, reponds avec une liste vide.
Reponds en JSON avec le schema : { "items": [{ "name", "category", "description", "tags", "quantity" }] }`

export const analyzeImage = async (imageBase64: string) => {
  const { googleApiKey } = config()

  const response = await $fetch<{
    candidates: { content: { parts: { text?: string }[] } }[]
  }>(`${GEMINI_API_URL}?key=${googleApiKey}`, {
    method: 'POST',
    headers: { 'content-type': 'application/json' },
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

  const text = response.candidates?.[0]?.content?.parts?.find((part) => part.text)?.text
  if (!text) throw new Error('Gemini did not return any text')

  log.info('Gemini raw response', text)

  const parsed = parseGeminiJson(text)
  const validated = responseSchema.parse(parsed)
  return validated.items
}
