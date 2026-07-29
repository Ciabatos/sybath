import fs from "fs"
import path from "path"

export async function removeFiles(files, rootDir = "plop-generators") {
  const removedFiles = []
  const normalizedFiles = files.flat()

  for (const file of normalizedFiles) {
    if (file.includes("answerHistory")) {
      console.log(`Pominięto historię: ${file}`)
      continue
    }

    const filePath = path.resolve(rootDir, file)

    if (!fs.existsSync(filePath)) {
      continue
    }

    await fs.promises.rm(filePath, {
      recursive: true,
      force: true,
    })
    console.log(file)
    removedFiles.push(file)
  }

  return `Usunięto ${removedFiles.length} plików.`
}
