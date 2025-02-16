// export function convertObjToMap(obj: Record<string, unknown>): Map<string, unknown> {
//   const map = new Map<string, unknown>()

//   Object.entries(obj).forEach(([key, value]) => {
//     map.set(key, value)
//   })

//   console.log(map, "dadas")
//   return map
// }

export function arrayToObjectKeyId<T extends { id: number }>(arr: T[]): { [key: number]: T } {
  return arr.reduce(
    (acc, item) => {
      acc[item.id] = item // Kluczem będzie id, a wartością obiekt
      return acc
    },
    {} as { [key: number]: T },
  )
}
