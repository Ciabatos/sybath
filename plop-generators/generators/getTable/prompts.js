import { historyExists, loadPreviousAnswers } from "../../helpers/answerHistory.js"
import { mapSQLTypeToTS, snakeToCamel } from "../../helpers/helpers.js"
import { fetchColumns, fetchSchemas, fetchTables } from "../../helpers/queries.js"
import { resolveGetTable } from "./resolve.js"

export async function getTablePrompts(inquirer) {
  const schemas = await fetchSchemas()
  if (schemas.length === 0) throw new Error("Brak dostępnych schematów")

  const { schema } = await inquirer.prompt([
    { type: "list", name: "schema", message: "Wybierz schemat:", choices: schemas },
  ])

  const tables = await fetchTables(schema)
  if (tables.length === 0) throw new Error(`Brak tabel w schemacie: ${schema}`)

  const { table } = await inquirer.prompt([
    { type: "list", name: "table", message: "Wybierz tabelę:", choices: tables },
  ])

  // ----- previous-answers shortcut -----
  const historyKey = `${schema}_${table}`
  let previousAnswers = null
  if (historyExists("getTable", historyKey)) {
    const { usePrevious } = await inquirer.prompt([
      {
        type: "list",
        name: "usePrevious",
        message: `Znaleziono zapisane ustawienia plop.js dla ${schema}.${table}. Czy wczytać poprzednie ustawienia?`,
        choices: [
          { name: "Tak", value: true },
          { name: "Nie", value: false },
        ],
      },
    ])
    previousAnswers = loadPreviousAnswers("getTable", historyKey)
    if (usePrevious) {
      console.log("Wczytano poprzednie ustawienia:", previousAnswers)
      return previousAnswers
    }
  }

  // ----- preview columns for the checkboxes -----
  const rows = await fetchColumns(schema, table)
  const jsonbColumns = rows.filter((col) => mapSQLTypeToTS(col.data_type) === "jsonb")
  if (jsonbColumns.length > 0) {
    const cols = jsonbColumns.map((c) => c.column_name).join(", ")
    throw new Error(`❌ Aborting generator: jsonb columns detected (${cols}). Please add data type for jsonb manually.`)
  }

  const previewColumns = rows.map((col) => ({
    name: col.column_name,
    camelName: snakeToCamel(col.column_name),
    tsType: mapSQLTypeToTS(col.data_type),
  }))

  const { selectedColumnsIndex } = await inquirer.prompt([
    {
      type: "checkbox",
      name: "selectedColumnsIndex",
      message: "Wybierz kolumny dla indexu do szybkiego wyszukiwania krotki po stronie Aplikacji:",
      default: previousAnswers?.promptAnswers?.selectedColumnsIndex ?? null,
      choices: previewColumns.map((f) => ({
        name: `${f.name} (${f.tsType})`,
        value: f.name,
        checked: false,
      })),
      validate: (answer) => (answer.length < 1 ? "Musisz zaznaczyć przynajmniej jedną kolumnę." : true),
    },
  ])

  const { paramsColumns } = await inquirer.prompt([
    {
      type: "checkbox",
      name: "paramsColumns",
      message:
        "Wybierz parametry dla zbieranych rekordów po stronie SERWERA (przykład dla parametru mapId zbierz wszystkie mapTiles):",
      default: previousAnswers?.promptAnswers?.paramsColumns ?? null,
      choices: previewColumns.map((f) => ({ name: `${f.name} (${f.tsType})`, value: f.name })),
      validate: (answer) => (answer.length < 1 ? "Musisz zaznaczyć przynajmniej jedną kolumnę." : true),
    },
  ])

  const { generateMutation } = await inquirer.prompt([
    {
      type: "list",
      name: "generateMutation",
      message: "Czy chcesz wygenerować także hook useMutate ? Służy do szybkiego odświeżania UI po użyciu akcji",
      default: previousAnswers?.promptAnswers?.generateMutation ?? null,
      choices: [
        { name: "Nie", value: false },
        { name: "Tak", value: true },
      ],
    },
  ])

  const { mutationMergeOldData } = await inquirer.prompt([
    {
      type: "list",
      name: "mutationMergeOldData",
      message:
        "Czy zmergować stare dane z atomu do nowych danych przy użyciu Mutate ? (pytanie pomocnicze : Czy mój optimistic update dotyczy tylko części istniejących danych, które muszę scalić z obecnym cache, zamiast zastępować cały stan?) ",
      default: previousAnswers?.promptAnswers?.mutationMergeOldData ?? null,
      choices: [
        { name: "Nie", value: false },
        { name: "Tak", value: true },
      ],
      when: () => generateMutation === true,
    },
  ])

  return resolveGetTable({
    schema,
    table,
    selectedColumnsIndex,
    paramsColumns,
    generateMutation,
    mutationMergeOldData,
  })
}
