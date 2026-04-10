import { on } from '~/system/event-bus'
import { rebuildIndex } from './index'

export const registerSearchEventHandlers = () => {
  on('item-changed', () => rebuildIndex())
  on('location-changed', () => rebuildIndex())
}
