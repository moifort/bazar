import { normalizeText } from '~/utils/text'
import type { ItemPreview } from './types'

// A drawer, a shelf, a cupboard are levels of the location hierarchy
// (`zone` / `storage`), never items. The AI photographs the furniture together
// with what it holds, so the words it comes back with are listed here — accent
// folded, since the match runs on the normalized name.
const STORAGE_UNITS = [
  'tiroir',
  'etagere',
  'placard',
  'armoire',
  'commode',
  'penderie',
  'dressing',
  'buffet',
  'vaisselier',
  'bibliotheque',
  'meuble',
  'rangement',
  'casier',
  'caisson',
  'compartiment',
  'cagibi',
  'cellier',
  'boite de rangement',
  'bac de rangement',
  'panier de rangement',
]

// Anchored at the start and tolerant of a plural, so "Tiroir", "Tiroir 1" and
// "Etageres du haut" match while "Boite de cereales" does not. Deliberately
// absent from the list: tablette, coffre, malle and boite on their own — they
// name real items at least as often as they name a container.
const STORAGE_UNIT = new RegExp(`^(${STORAGE_UNITS.join('|')})s?\\b`)

export const isStorageUnit = (name: string) => STORAGE_UNIT.test(normalizeText(name))

export const withoutStorageUnits = (previews: ItemPreview[]) =>
  previews.filter((preview) => !isStorageUnit(preview.name))
