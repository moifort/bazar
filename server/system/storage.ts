const ISO_DATE = /^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}/

const dateReviver = (_key: string, value: unknown) =>
  typeof value === 'string' && ISO_DATE.test(value) ? new Date(value) : value

type StorageItem<T> = { base: string; key: string; value: T }

const parseRaw = <T>(text: string) => {
  try {
    return JSON.parse(text, dateReviver) as T
  } catch {
    return (ISO_DATE.test(text) ? new Date(text) : text) as T
  }
}

export const createTypedStorage = <T>(namespace: string) => {
  const raw = useStorage(namespace)
  return {
    getItem: async (key: string): Promise<T | null> => {
      const text = await raw.getItemRaw<string>(key)
      return text ? parseRaw<T>(text) : null
    },
    getItems: async (keys: string[]) =>
      Promise.all(
        keys.map(async (key) => {
          const text = await raw.getItemRaw<string>(key)
          return text
            ? ({ base: namespace, key, value: parseRaw<T>(text) } as StorageItem<T>)
            : null
        }),
      ).then((items) => items.filter((item): item is StorageItem<T> => item !== null)),
    getKeys: (base?: string) => raw.getKeys(base),
    setItem: (key: string, value: T) => raw.setItem(key, value as Record<string, unknown>),
    removeItem: (key: string) => raw.removeItem(key),
  }
}
