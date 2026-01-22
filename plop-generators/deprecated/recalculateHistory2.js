import fs from "fs"
import nodePlop from "node-plop"
import path from "path"

async function replayAllHistory() {
  const plop = await nodePlop(path.resolve("./plopfile.js"))

  const HISTORY_ROOT = path.resolve("plop-generators/answerHistory")
  const generators = fs.readdirSync(HISTORY_ROOT).filter((f) => fs.statSync(path.join(HISTORY_ROOT, f)).isDirectory())

  for (const generatorName of generators) {
    const generator = plop.getGenerator(generatorName)

    const dir = path.join(HISTORY_ROOT, generatorName)
    const files = fs.readdirSync(dir).filter((f) => f.endsWith(".json"))

    for (const file of files) {
      const historyAnswers = JSON.parse(fs.readFileSync(path.join(dir, file), "utf-8"))

      console.log(`\n▶ Running generator "${generatorName}" from file "${file}"`)

      // 1️⃣ Wywołaj prompts z zapisanymi odpowiedziami
      const answers = await generator.runPrompts(historyAnswers.promptAnswers || historyAnswers)

      // 2️⃣ Wykonaj akcje
      const results = await generator.runActions(answers)

      console.log(`✔ Finished: ${generatorName} - ${file}`)
      console.log(results)
    }
  }
}

replayAllHistory()
