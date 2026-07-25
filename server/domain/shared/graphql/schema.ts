import { builder } from '~/domain/shared/graphql/builder'

// Custom scalars (must be registered before types that reference them)
import '~/domain/shared/graphql/scalars'

// Location domain
import '~/domain/location/infrastructure/graphql/types'
import '~/domain/location/infrastructure/graphql/inputs'
import '~/domain/location/infrastructure/graphql/queries'
import '~/domain/location/infrastructure/graphql/mutations'

// Scan domain
import '~/domain/scan/infrastructure/graphql/types'
import '~/domain/scan/infrastructure/graphql/mutations'

// Item domain
import '~/domain/item/infrastructure/graphql/enums'
import '~/domain/item/infrastructure/graphql/types'
import '~/domain/item/infrastructure/graphql/inputs'
import '~/domain/item/infrastructure/graphql/queries'
import '~/domain/item/infrastructure/graphql/mutations'

// Reminder domain
import '~/domain/reminder/infrastructure/graphql/enums'
import '~/domain/reminder/infrastructure/graphql/types'
import '~/domain/reminder/infrastructure/graphql/inputs'
import '~/domain/reminder/infrastructure/graphql/queries'
import '~/domain/reminder/infrastructure/graphql/mutations'

// Search domain
import '~/domain/search/infrastructure/graphql/types'
import '~/domain/search/infrastructure/graphql/queries'

// Dashboard domain
import '~/domain/dashboard/infrastructure/graphql/types'
import '~/domain/dashboard/infrastructure/graphql/queries'

// Notification domain
import '~/domain/notification/infrastructure/graphql/mutations'

// Changelog (system)
import '~/system/changelog/infrastructure/graphql/types'
import '~/system/changelog/infrastructure/graphql/queries'

// Account (system)
import '~/system/account/infrastructure/graphql/mutations'

export const schema = builder.toSchema()
