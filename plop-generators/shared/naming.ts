export const snakeToCamel = (str: string, removePrefix = false): string => {
  const processed = removePrefix ? str.replace(/^p_/, "") : str
  return processed.replace(/_([a-z])/g, (_, letter) => letter.toUpperCase())
}

export const snakeToPascal = (str: string): string => {
  return str.replace(/(^|_)([a-z])/g, (_, __, c) => c.toUpperCase())
}

export const camelToSnake = (str: string): string => {
  return str.replace(/[A-Z]/g, letter => `_${letter.toLowerCase()}`)
}

export interface NamingVariants {
  original: string
  camel: string
  pascal: string
  snake: string
}

export const getAllNamingVariants = (name: string): NamingVariants => ({
  original: name,
  camel: snakeToCamel(name),
  pascal: snakeToPascal(name),
  snake: name.includes("_") ? name : camelToSnake(name),
})
