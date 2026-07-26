import { describe, expect, test } from 'bun:test'
import { isStorageUnit, withoutStorageUnits } from './business-rules'
import { PreviewId } from './primitives'
import type { ItemPreview } from './types'

describe('isStorageUnit', () => {
  test.each([
    'Tiroir',
    'Tiroir 1',
    'Étagère',
    'Étagères du haut',
    'Placard sous l’évier',
    'Armoire à pharmacie',
    'Meuble TV',
    'Boîte de rangement',
  ])('%s is a location, not an item', (name) => {
    expect(isStorageUnit(name)).toBe(true)
  })

  test.each([
    'Boîte de céréales',
    'Canapé',
    'Table basse',
    'Tablette tactile',
    'Perceuse Bosch',
    'Meubl',
  ])('%s stays an item', (name) => {
    expect(isStorageUnit(name)).toBe(false)
  })
})

describe('withoutStorageUnits', () => {
  const preview = (name: string): ItemPreview => ({
    previewId: PreviewId(crypto.randomUUID()),
    name,
    description: '',
    tags: [],
    quantity: 1,
  })

  test('drops the furniture the AI photographed along with its contents', () => {
    const kept = withoutStorageUnits([preview('Tiroir 1'), preview('Marteau'), preview('Étagère')])

    expect(kept.map(({ name }) => name)).toEqual(['Marteau'])
  })

  test('leaves a batch of real items untouched', () => {
    const previews = [preview('Marteau'), preview('Tournevis')]

    expect(withoutStorageUnits(previews)).toEqual(previews)
  })
})
