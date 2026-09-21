import fs from "fs"
import path from "path"

export function getHistoryDir(generatorName) {
  const dir = path.resolve(process.cwd(), `plop-generators/answerHistory/${generatorName}`)
  if (!fs.existsSync(dir)) fs.mkdirSync(dir, { recursive: true })
  return dir
}

export function getHistoryPath(generatorName, key) {
  return path.join(getHistoryDir(generatorName), `${key}_answers.json`)
}

export function loadPreviousAnswers(generatorName, key) {
  const file = getHistoryPath(generatorName, key)
  if (!fs.existsSync(file)) return null
  try {
    return JSON.parse(fs.readFileSync(file, "utf-8"))
  } catch {
    return null
  }
}

export function historyExists(generatorName, key) {
  return fs.existsSync(getHistoryPath(generatorName, key))
}
