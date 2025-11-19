/* eslint-disable @typescript-eslint/no-explicit-any */
export function snakeToCamel(str: string) {
  return str.replace(/_([a-z])/g, (_, letter) => letter.toUpperCase())
}

export function snakeToCamelKeys(obj: any) {
  const newObj: any = {}

  for (const key in obj) {
    const camelKey = snakeToCamel(key)
    newObj[camelKey] = obj[key]
  }

  return newObj
}

export function snakeToCamelRows(rows: any[]) {
  return rows.map((row) => snakeToCamelKeys(row))
}
