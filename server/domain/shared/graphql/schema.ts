import { builder } from '~/domain/shared/graphql/builder'

// Custom scalars (must be registered before types that reference them)
import '~/domain/shared/graphql/scalars'

export const schema = builder.toSchema()
