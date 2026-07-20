import type { Migration } from '~/system/migration/types'
import { migration0001 } from './0001-absent-over-null'

export const migrations: Migration[] = [migration0001]
