import type { Migration } from '~/system/migration/types'
import { migration0001 } from './0001-absent-over-null'
import { migration0002 } from './0002-item-tags'

export const migrations: Migration[] = [migration0001, migration0002]
