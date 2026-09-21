import { historyExists, loadPreviousAnswers } from "../../helpers/answerHistory.js"
import { fetchFunction, fetchMethodResultColumns, fetchSchemas } from "../../helpers/queries.js"
import { resolveGetMethodFetcher } from "./resolve.js"

export async function getMethodFetcherPrompts(inquirer) {
  const schemas = await fetchSchemas()
  if (schemas.length === 0) throw new Error("Brak dostępnych schematów")

  const { schema } = await inquirer.prompt([
    { type: "list", name: "schema", message: "Wybierz schemat:", choices: schemas },
  ])

  const methods = await fetchFunction(schema)
  if (methods.length === 0) throw new Error(`Brak metod w schemacie: ${schema}`)

  const { method } = await inquirer.prompt([
    { type: "list", name: "method", message: "Wybierz metodę:", choices: methods },
  ])

  const historyKey = `${schema}_${method}`
  let previousAnswers = null
  if (historyExists("getMethodFetcher", historyKey)) {
    const { usePrevious } = await inquirer.prompt([
      {
        type: "list",
        name: "usePrevious",
        message: `Znaleziono zapisane ustawienia plop.js dla ${schema}.${method}. Czy wczytać poprzednie ustawienia?`,
        choices: [
          { name: "Tak", value: true },
          { name: "Nie", value: false },
        ],
      },
    ])
    previousAnswers = loadPreviousAnswers("getMethodFetcher", historyKey)
    if (usePrevious) {
      console.log("Wczytano poprzednie ustawienia:", previousAnswers)
      return previousAnswers
    }
  }

  // fetch preview columns for the checkbox prompt
  const { resultColumns } = await fetchMethodResultColumns(schema, method)

  const { selectedColumnsIndex } = await inquirer.prompt([
    {
      type: "checkbox",
      name: "selectedColumnsIndex",
      message: "Wybierz kolumny dla indexu do szybkiego wyszukiwania krotki po stronie Aplikacji:",
      default: previousAnswers?.promptAnswers?.selectedColumnsIndex ?? null,
      choices: resultColumns.map((f) => ({
        name: `${f.camelName} (${f.type})`,
        value: f.camelName,
        checked: false,
      })),
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
        "Czy zmergować stare dane z atomu do nowych danych przy użyciu Mutate ? (pytanie pomocnicze : Czy mój optimistic update dotyczy tylko części istniejących danych, które muszę scalić z obecnym cache, zamiast zastępować cały stan?)",
      default: previousAnswers?.promptAnswers?.mutationMergeOldData ?? null,
      choices: [
        { name: "Nie", value: false },
        { name: "Tak", value: true },
      ],
      when: () => generateMutation === true,
    },
  ])

  return resolveGetMethodFetcher({
    schema,
    method,
    selectedColumnsIndex,
    generateMutation,
    mutationMergeOldData,
  })
}
