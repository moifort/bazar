export default defineNitroConfig({
  compatibilityDate: '2026-02-06',
  experimental: { asyncContext: true },
  srcDir: 'server',
  ignore: ['test/**', '**/*.test.ts'],
  rollupConfig: {
    treeshake: {
      moduleSideEffects: (id) => id.includes('/graphql/') || id.includes('node_modules'),
    },
  },
  runtimeConfig: {
    apiToken: '',
    googleApiKey: '',
  },
  storage: {
    'migration-meta': { driver: 'fs', base: './.data/db/migration-meta' },
    items: { driver: 'fs', base: './.data/db/items' },
    places: { driver: 'fs', base: './.data/db/places' },
    rooms: { driver: 'fs', base: './.data/db/rooms' },
    zones: { driver: 'fs', base: './.data/db/zones' },
    storages: { driver: 'fs', base: './.data/db/storages' },
    images: { driver: 'fs', base: './.data/db/images' },
    'scan-cache': { driver: 'fs', base: './.data/db/scan-cache' },
  },
})
