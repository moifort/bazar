import { createTypedStorage } from '~/system/storage'
import type { Image } from '../types'

const imagesStorage = () => createTypedStorage<Image>('images')

export const findBy = (id: string) => imagesStorage().getItem(id)

export const save = (image: Image) => imagesStorage().setItem(image.id, image)

export const remove = (id: string) => imagesStorage().removeItem(id)
