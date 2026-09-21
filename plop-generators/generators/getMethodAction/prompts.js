import { historyExists, loadPreviousAnswers } from "../../helpers/answerHistory.js"
import { fetchFucntionForAction, fetchSchemas } from "../../helpers/queries.js"
import { resolveGetMethodAction } from "./resolve.js"

export async function getMethodActionPrompts(inquirer) {
  const schemas = await fetchSchemas()
  if (schemas.length === 0) throw new Error("Brak dostępnych schematów")

  const { schema } = await inquirer.prompt([
    { type: "list", name: "schema", message: "Wybierz schemat:", choices: schemas },
  ])

  const methods = await fetchFucntionForAction(schema)
  if (methods.length === 0) throw new Error(`Brak metod w schemacie: ${schema}`)

  const { method } = await inquirer.prompt([
    { type: "list", name: "method", message: "Wybierz metodę:", choices: methods },
  ])

  const historyKey = `${schema}_${method}`
  if (historyExists("getMethodAction", historyKey)) {
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
    const previousAnswers = loadPreviousAnswers("getMethodAction", historyKey)
    if (usePrevious) {
      console.log("Wczytano poprzednie ustawienia:", previousAnswers)
      return previousAnswers
    }
  }

  return resolveGetMethodAction({ schema, method })
}
