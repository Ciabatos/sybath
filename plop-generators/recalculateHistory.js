import fs from "fs"
import path from "path"

const HISTORY_ROOT = path.resolve("plop-generators/answerHistory")

export default function recalculateHistory(plop) {
  plop.setGenerator("recalculateHistory", {
    description: "Replay saved generator answers",

    prompts: async (inquirer) => {
      // Zbierz dostępne typy generatorów
      const generatorDirs = fs
        .readdirSync(HISTORY_ROOT)
        .filter((f) => fs.statSync(path.join(HISTORY_ROOT, f)).isDirectory())

      if (generatorDirs.length === 0) {
        throw new Error("Brak zapisanych generatorów w historii")
      }

      // Krok 1: Wybierz typ generatora
      const { selectedGenerators } = await inquirer.prompt([
        {
          type: "checkbox",
          name: "selectedGenerators",
          message: "Wybierz typy generatorów do odtworzenia:",
          choices: generatorDirs,
          validate: (answer) => {
            if (answer.length < 1) {
              return "Musisz wybrać przynajmniej jeden typ generatora."
            }
            return true
          },
        },
      ])

      // Krok 2: Dla każdego wybranego typu, zbierz pliki
      const allSelectedFiles = []

      for (const generatorName of selectedGenerators) {
        const dir = path.join(HISTORY_ROOT, generatorName)
        const files = fs.readdirSync(dir).filter((f) => f.endsWith(".json"))

        if (files.length === 0) {
          console.warn(`⚠ Brak plików historii dla ${generatorName}`)
          continue
        }

        // Pytaj o pliki dla tego generatora
        const { selectedFiles } = await inquirer.prompt([
          {
            type: "checkbox",
            name: "selectedFiles",
            message: `Wybierz pliki dla ${generatorName}:`,
            choices: files.map((file) => ({
              name: file.replace(".json", "").replace(/_answers$/, ""),
              value: file,
              checked: true, // Domyślnie wszystkie zaznaczone
            })),
          },
        ])

        // Dodaj wybrane pliki do listy
        for (const file of selectedFiles) {
          allSelectedFiles.push({
            generatorName,
            fileName: file,
            displayName: `${generatorName} → ${file.replace(".json", "")}`,
            filePath: path.join(dir, file),
          })
        }
      }

      if (allSelectedFiles.length === 0) {
        throw new Error("Nie wybrano żadnych plików do odtworzenia")
      }

      // Pokaż podsumowanie
      console.log("\n📋 Wybrane pliki do odtworzenia:")
      allSelectedFiles.forEach((f) => console.log(`  • ${f.displayName}`))
      console.log("")

      return { selectedFiles: allSelectedFiles }
    },

    actions: (answers) => {
      const actions = []

      for (const fileInfo of answers.selectedFiles) {
        const savedAnswers = JSON.parse(fs.readFileSync(fileInfo.filePath, "utf-8"))

        actions.push({
          type: "runGeneratorWithAnswers",
          generatorName: fileInfo.generatorName,
          fileName: fileInfo.fileName,
          promptAnswers: savedAnswers.promptAnswers || savedAnswers,
        })
      }

      return actions
    },
  })

  // Action type do uruchamiania generatorów
  plop.setActionType("runGeneratorWithAnswers", async (answers, config, plopInstance) => {
    const { generatorName, fileName, promptAnswers } = config

    console.log(`\n${"=".repeat(60)}`)
    console.log(`▶ Uruchamiam: ${generatorName} - ${fileName}`)
    console.log(`${"=".repeat(60)}\n`)

    const generator = plopInstance.getGenerator(generatorName)

    if (!generator) {
      throw new Error(`❌ Generator "${generatorName}" nie istnieje`)
    }

    // Mock inquirer
    const mockInquirer = {
      prompt: async (questions) => {
        if (Array.isArray(questions)) {
          const result = {}
          for (const q of questions) {
            if (promptAnswers.hasOwnProperty(q.name)) {
              result[q.name] = promptAnswers[q.name]
              console.log(`  ✓ ${q.name}`)
            }
          }
          return result
        }
        const questionName = questions.name
        if (promptAnswers.hasOwnProperty(questionName)) {
          console.log(`  ✓ ${questionName}`)
          return { [questionName]: promptAnswers[questionName] }
        }
        return {}
      },
    }

    // Wykonaj prompts z mock inquirer
    console.log("📝 Ładuję zapisane odpowiedzi...\n")
    const processedAnswers = await generator.prompts(mockInquirer)

    console.log("\n✅ Kalkulacje zakończone\n🔨 Wykonuję akcje...\n")

    // Pobierz akcje
    const generatorActions =
      typeof generator.actions === "function" ? generator.actions(processedAnswers) : generator.actions

    // Import node-plop do wykonania akcji
    const nodePlop = await import("node-plop")
    const runner = nodePlop.default(process.cwd())

    let successCount = 0
    let skipCount = 0

    // Wykonaj każdą akcję
    for (let i = 0; i < generatorActions.length; i++) {
      const action = generatorActions[i]

      // Skip logic
      if (typeof action.skip === "function") {
        const skipReason = action.skip(processedAnswers)
        if (skipReason) {
          console.log(`  ⊘ [${i + 1}] Pominięto: ${skipReason}`)
          skipCount++
          continue
        }
      } else if (action.skip === true) {
        skipCount++
        continue
      }

      if (typeof action === "string") {
        continue
      }

      try {
        await runner.runActions([action], processedAnswers)
        const actionPath = action.path || action.pattern || ""
        console.log(`  ✓ [${i + 1}] ${action.type}: ${actionPath}`)
        successCount++
      } catch (error) {
        console.error(`  ✗ [${i + 1}] Błąd: ${error.message}`)
      }
    }

    console.log(`\n${"=".repeat(60)}`)
    console.log(`✅ Zakończono: ${successCount} akcji, ${skipCount} pominięto`)
    console.log(`${"=".repeat(60)}\n`)

    return `✅ ${generatorName} - ${fileName}`
  })
}
