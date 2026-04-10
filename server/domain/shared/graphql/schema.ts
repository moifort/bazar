import { builder } from '~/domain/shared/graphql/builder'

// Custom scalars (must be registered before types that reference them)
import '~/domain/shared/graphql/scalars'

// Location domain
import '~/domain/location/infrastructure/graphql/types'
import '~/domain/location/infrastructure/graphql/inputs'
import '~/domain/location/infrastructure/graphql/queries'
import '~/domain/location/infrastructure/graphql/mutations'

// Item domain
import '~/domain/item/infrastructure/graphql/enums'
import '~/domain/item/infrastructure/graphql/types'
import '~/domain/item/infrastructure/graphql/inputs'
import '~/domain/item/infrastructure/graphql/queries'
import '~/domain/item/infrastructure/graphql/mutations'

export const schema = builder.toSchema()
