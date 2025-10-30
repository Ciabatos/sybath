import { FieldDefinition } from "./type-mapping"

export const createFieldChoices = (fields: FieldDefinition[]) => {
  return fields.map((f) => ({
    name: `${f.name} (${f.tsType})`,
    value: f.name,
    checked: false,
  }))
}

export const createIndexPrompt = (fields: FieldDefinition[]) => ({
  type: "checkbox" as const,
  name: "selectedColumnsIndex",
  message: "Wybierz kolumny dla indexu:",
  choices: createFieldChoices(fields),
  validate: (answer: string[]) => {
    if (answer.length < 1) {
      return "Musisz zaznaczyć przynajmniej jedną kolumnę."
    }
    return true
  },
})

export const createParamsPrompt = (fields: FieldDefinition[]) => ({
  type: "checkbox" as const,
  name: "paramsColumns",
  message: "Wybierz kolumny jako parametry funkcji (opcjonalnie):",
  choices: fields.map((f) => ({
    name: `${f.name} (${f.tsType})`,
    value: f.name,
  })),
})

export interface IndexConfig {
  fields: FieldDefinition[]
  methodName: string
  methodArgs: string
  typeRecordName: string
}

export const createIndexConfig = (
  selectedFields: FieldDefinition[]
): IndexConfig => {
  // Dodaj pascalName do każdego pola
  selectedFields.forEach((f) => {
    f.pascalName = f.camelName.charAt(0).toUpperCase() + f.camelName.slice(1)
  })

  const typeRecordName = selectedFields.map((f) => f.pascalName).join("")
  const methodName =
    selectedFields.length > 1 ? "arrayToObjectKeysId" : "arrayToObjectKeyId"
  const methodArgs = selectedFields.map((f) => `"${f.camelName}"`).join(", ")

  return {
    fields: selectedFields,
    methodName,
    methodArgs,
    typeRecordName,
  }
}

export const parseFunctionArgs = (argsStr: string): FieldDefinition[] => {
  if (!argsStr) return []

  return argsStr
    .split(",")
    .map((arg) => {
      const trimmed = arg.trim()
      const spaceIndex = trimmed.indexOf(" ")
      if (spaceIndex === -1) return null

      const name = trimmed.substring(0, spaceIndex)
      const sqlType = trimmed.substring(spaceIndex + 1)
      const camelName = name.replace(/^p_/, "").replace(/_([a-z])/g, (_, l) => l.toUpperCase())

      return {
        name,
        camelName,
        tsType: sqlType, // będzie zmapowane przez mapSQLTypeToTS
        optional: "",
      }
    })
    .filter((f): f is FieldDefinition => f !== null)
}

export const parseFunctionReturnColumns = (
  returnType: string
): FieldDefinition[] => {
  // Jeśli nie jest TABLE type, zwróć prosty typ
  if (!returnType.startsWith("TABLE(")) {
    return [
      {
        name: "result",
        camelName: "result",
        tsType: returnType,
        optional: "",
      },
    ]
  }

  // Parsuj TABLE(col1 type1, col2 type2, ...)
  const tableMatch = returnType.match(/TABLE\((.*?)\)/)
  if (!tableMatch) {
    return [{ name: "result", camelName: "result", tsType: "any", optional: "" }]
  }

  const columnsStr = tableMatch[1]
  return columnsStr
    .split(",")
    .map((col) => {
      const trimmed = col.trim()
      const spaceIndex = trimmed.indexOf(" ")
      if (spaceIndex === -1) return null

      const name = trimmed.substring(0, spaceIndex)
      const type = trimmed.substring(spaceIndex + 1)
      const camelName = name.replace(/_([a-z])/g, (_, l) => l.toUpperCase())

      return {
        name,
        camelName,
        tsType: type,
        optional: "",
      }
    })
    .filter((f): f is FieldDefinition => f !== null)
}
