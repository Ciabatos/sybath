
type TServerEntity<TData = unknown> = {
  raw: TData[] 
  apiPath: string
}

type TFallbackMap = Record<string, unknown[]>

export function createSwrFallback(
  ...entities: TServerEntity<any>[]
): TFallbackMap {
  const fallbackMap: TFallbackMap = {}
  
  for (const entity of entities) {
    if (entity && entity.apiPath && entity.raw) {
      fallbackMap[entity.apiPath] = entity.raw
    }
  }

  return fallbackMap
}