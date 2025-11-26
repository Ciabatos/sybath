import { ForeignKeyInfo } from "@/methods/functions/map/fkzbazy"
import { produce } from "immer"

export function joinByForeignKeys<TMain extends Record<string, any>>(
  mainObject: Record<string, TMain>,
  foreignData: Record<string, Record<string, any>>, // np. { terrainTypes, buildings, users }
  foreignKeys: ForeignKeyInfo<TMain>[],
  options?: { oldDataToUpdate?: Record<string, any>; separator?: string },
): Record<string, any> {
  const sep = options?.separator ?? "-"

  const createCompositeKey = (item: TMain, keys: (keyof TMain)[]) => keys.map((k) => item[k]).join(sep)

  const mergeItem = (item: TMain) => {
    const result: any = { ...item }

    foreignKeys.forEach((fk) => {
      const foreignObj = foreignData[fk.foreignTable]
      if (!foreignObj) return

      if (Array.isArray(fk.mainColumn)) {
        const key = createCompositeKey(item, fk.mainColumn)
        result[fk.foreignTable] = foreignObj[key]
      } else {
        const foreignKey = fk.foreignColumn ?? "id"
        result[fk.foreignTable] = foreignObj[item[fk.mainColumn] as any]
      }
    })

    return result
  }

  const entries = Object.entries(mainObject)

  if (options?.oldDataToUpdate) {
    return produce(options.oldDataToUpdate, (draft) => {
      entries.forEach(([key, data]) => {
        if (draft[key]) draft[key] = mergeItem(data)
      })
    })
  }

  return Object.fromEntries(entries.map(([key, data]) => [key, mergeItem(data)]))
}
