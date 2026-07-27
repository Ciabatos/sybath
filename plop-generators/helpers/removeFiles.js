import fs from "fs"
import path from "path"

export async function removeFiles(files) {
  const removedFiles = []

  for (const file of files) {
    const filePath = path.resolve(file)

    if (!fs.existsSync(filePath)) {
      continue
    }

    await fs.promises.rm(filePath, {
      recursive: true,
      force: true,
    })

    removedFiles.push(file)
  }

  return `Usunięto ${removedFiles.length} plików.`
}
