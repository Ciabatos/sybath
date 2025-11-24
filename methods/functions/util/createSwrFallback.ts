
type TServerEntity<TData = unknown> = {
  raw: TData[] 
  apiPath: string
}

type TFallbackMap = Record<string, unknown[]>

export function createSwrFallback(
  ...entities: TServerEntity<any>[]
): TFallbackMap {
  return entities.reduce((acc: TFallbackMap, entity) => {
    if (entity && entity.apiPath && entity.raw) {
      acc[entity.apiPath] = entity.raw
    }
    return acc
  }, {} as TFallbackMap)
}