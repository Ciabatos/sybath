// export function convertObjToMap(obj: Record<string, unknown>): Map<string, unknown> {
//   const map = new Map<string, unknown>()

//   Object.entries(obj).forEach(([key, value]) => {
//     map.set(key, value)
//   })

//   console.log(map, "dadas")
//   return map
// }

export function arrayToObjectKeyId<T extends Record<K, number>, K extends keyof T>(
  key: K, // The key property name (e.g., 'id')
  arr: T[], // The array of objects
): { [key: number]: T } {
  return arr.reduce(
    (acc, item) => {
      acc[item[key]] = item // Use the provided key to access the value
      return acc
    },
    {} as { [key: number]: T },
  )
}
