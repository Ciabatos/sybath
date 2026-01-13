import fs from "fs"
import path from "path"

const HISTORY_ROOT = path.resolve("plop-generators/answerHistory")

export default function recalculateHistory(plop) {
  plop.setGenerator("recalculateHistory", {
    description: "Replay saved generator answers",

    prompts: async (inquirer) => {
      // Zbierz wszystkie pliki historii z wszystkich generatorów
      const historyFiles = []

      const generatorDirs = fs
        .readdirSync(HISTORY_ROOT)
        .filter((f) => fs.statSync(path.join(HISTORY_ROOT, f)).isDirectory())

      for (const generatorName of generatorDirs) {
        const dir = path.join(HISTORY_ROOT, generatorName)
        const files = fs.readdirSync(dir).filter((f) => f.endsWith(".json"))

        for (const file of files) {
          historyFiles.push({
            generatorName,
            fileName: file,
            displayName: `${generatorName} → ${file.replace(".json", "")}`,
            filePath: path.join(dir, file),
          })
        }
      }

      if (historyFiles.length === 0) {
        throw new Error("Brak zapisanych plików historii")
      }

      // Jeden prompt - wybór plików do odtworzenia
      const { selectedFiles } = await inquirer.prompt([
        {
          type: "checkbox",
          name: "selectedFiles",
          message: "Wybierz pliki historii do odtworzenia:",
          choices: historyFiles.map((f) => ({
            name: f.displayName,
            value: f,
          })),
          validate: (answer) => {
            if (answer.length < 1) {
              return "Musisz wybrać przynajmniej jeden plik."
            }
            return true
          },
        },
      ])

      return { selectedFiles }
    },

    actions: (answers) => {
      const actions = []

      for (const fileInfo of answers.selectedFiles) {
        // Wczytaj zapisane odpowiedzi
        const savedAnswers = JSON.parse(fs.readFileSync(fileInfo.filePath, "utf-8"))

        actions.push({
          type: "runGenerator",
          generatorName: fileInfo.generatorName,
          fileName: fileInfo.fileName,
          // Przekaż tylko promptAnswers - reszta będzie przeliczona
          promptAnswers: savedAnswers.promptAnswers || savedAnswers,
        })
      }

      return actions
    },
  })

  // Custom action type do uruchamiania generatorów
  plop.setActionType("runGenerator", async (answers, config) => {
    const { generatorName, fileName, promptAnswers } = config

    console.log(`\n${"=".repeat(60)}`)
    console.log(`▶ Uruchamiam: ${generatorName} - ${fileName}`)
    console.log(`${"=".repeat(60)}`)

    const generator = plop.getGenerator(generatorName)

    if (!generator) {
      throw new Error(`❌ Generator "${generatorName}" nie istnieje`)
    }

    // Pobierz oryginalną funkcję prompts
    const originalPrompts = generator.prompts

    if (typeof originalPrompts !== "function") {
      throw new Error(`❌ Generator "${generatorName}" nie ma funkcji prompts`)
    }

    // Stwórz mock inquirer, który zwraca zapisane odpowiedzi dla promptów
    const mockInquirer = {
      prompt: async (questions) => {
        // Obsłuż tablicę pytań
        if (Array.isArray(questions)) {
          const result = {}
          for (const q of questions) {
            if (promptAnswers.hasOwnProperty(q.name)) {
              result[q.name] = promptAnswers[q.name]
              console.log(`  ✓ Użyto zapisanej odpowiedzi: ${q.name}`)
            } else {
              console.warn(`  ⚠ Brak zapisanej odpowiedzi dla: ${q.name}`)
            }
          }
          return result
        }

        // Obsłuż pojedyncze pytanie
        const questionName = questions.name
        if (promptAnswers.hasOwnProperty(questionName)) {
          console.log(`  ✓ Użyto zapisanej odpowiedzi: ${questionName}`)
          return { [questionName]: promptAnswers[questionName] }
        } else {
          console.warn(`  ⚠ Brak zapisanej odpowiedzi dla: ${questionName}`)
          return {}
        }
      },
    }

    console.log("\n📝 Wykonuję kalkulacje generatora z zapisanymi odpowiedziami...\n")

    // Wykonaj oryginalną funkcję prompts z mock inquirer
    // To wykona wszystkie kalkulacje (fetchColumns, snakeToPascal, createMethodGetRecords, etc.)
    const processedAnswers = await originalPrompts(mockInquirer)

    console.log("\n✅ Kalkulacje zakończone pomyślnie")
    console.log("\n🔨 Wykonuję akcje generatora...\n")

    // Pobierz akcje z oryginalnego generatora (już z przetworzonymi danymi)
    const generatorActions =
      typeof generator.actions === "function" ? generator.actions(processedAnswers) : generator.actions

    // KLUCZOWA ZMIANA: Użyj wbudowanego mechanizmu Plop do wykonania akcji
    // Zamiast ręcznie wykonywać akcje, wywołaj je przez Plop
    let successCount = 0
    let skipCount = 0
    const ActionRunner = plop.getActionTypeList()

    for (let i = 0; i < generatorActions.length; i++) {
      const action = generatorActions[i]

      // Sprawdź czy akcja powinna być pominięta
      if (typeof action.skip === "function") {
        const skipReason = action.skip(processedAnswers)
        if (skipReason) {
          console.log(`  ⊘ Pominięto akcję ${i + 1}: ${skipReason}`)
          skipCount++
          continue
        }
      } else if (action.skip === true) {
        console.log(`  ⊘ Pominięto akcję ${i + 1}`)
        skipCount++
        continue
      }

      // Jeśli to string (komentarz), wyświetl go
      if (typeof action === "string") {
        console.log(`  💬 ${action}`)
        continue
      }

      // Wykonaj akcję
      try {
        // Użyj wewnętrznego API Plop do wykonania akcji
        const actionResult = await plop.renderString(action.template || "", processedAnswers)

        // Dla akcji 'add' i 'modify' użyj plop.getHelper lub bezpośrednio wykonaj
        if (action.type === "add") {
          const renderedPath = await plop.renderString(action.path, processedAnswers)
          console.log(`  ✓ [${i + 1}/${generatorActions.length}] add: ${renderedPath}`)

          // Wykonaj akcję add przez plop
          const addAction = plop.getActionType("add")
          if (addAction) {
            await addAction(processedAnswers, action)
          }
          successCount++
        } else if (action.type === "modify") {
          const renderedPath = await plop.renderString(action.path, processedAnswers)
          console.log(`  ✓ [${i + 1}/${generatorActions.length}] modify: ${renderedPath}`)

          // Wykonaj akcję modify przez plop
          const modifyAction = plop.getActionType("modify")
          if (modifyAction) {
            await modifyAction(processedAnswers, action)
          }
          successCount++
        } else {
          // Dla custom action types
          const customAction = plop.getActionType(action.type)
          if (customAction) {
            await customAction(processedAnswers, action)
            console.log(`  ✓ [${i + 1}/${generatorActions.length}] ${action.type}`)
            successCount++
          } else {
            console.warn(`  ⚠ Nieznany typ akcji: ${action.type}`)
          }
        }
      } catch (error) {
        console.error(`  ✗ Błąd w akcji ${i + 1}:`, error.message)
        // Nie rzucaj błędu, kontynuuj z następnymi akcjami
      }
    }

    console.log(`\n${"=".repeat(60)}`)
    console.log(`✅ Generator "${generatorName}" zakończony pomyślnie`)
    console.log(`   Wykonano: ${successCount} akcji`)
    if (skipCount > 0) {
      console.log(`   Pominięto: ${skipCount} akcji`)
    }
    console.log(`${"=".repeat(60)}\n`)

    return `✅ ${generatorName} - ${fileName} (${successCount} akcji)`
  })
}
