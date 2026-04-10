import { createStorage } from 'unstorage'
import memoryDriver from 'unstorage/drivers/memory'

// Mock Nitro globals for schema generation (runs outside Nitro context)
// @ts-expect-error — global mock
globalThis.useStorage = () => createStorage({ driver: memoryDriver() })

const { printSchema } = await import('graphql')
const { schema } = await import('../server/domain/shared/graphql/schema')

const sdl = printSchema(schema)
await Bun.write('shared/schema.graphql', sdl)

process.stdout.write(`Exported GraphQL schema to shared/schema.graphql\n`)
