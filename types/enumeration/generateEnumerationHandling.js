import fs from "fs"
import path from "path"

const panelsPath = path.resolve("./types/panels")
const enumerationPath = path.resolve("./types/enumeration")

const folders = fs.readdirSync(panelsPath, { withFileTypes: true }).filter((dir) => dir.isDirectory())

folders.forEach((folder) => {
  const panelName = folder.name

  const enumName = "EPanels" + panelName.replace(/^panel/, "").replace(/([A-Z])/g, "$1")

  const folderPath = path.join(panelsPath, panelName)

  const txtFiles = fs.readdirSync(folderPath).filter((file) => file.endsWith(".txt"))

  const entries = txtFiles.map((file) => path.basename(file, ".txt"))

  const output = `"use client"

export enum ${enumName} {
${entries.map((entry) => `  ${entry} = "${entry}",`).join("\n")}
}
`

  const outputFile = path.join(enumerationPath, `${enumName}.ts`)

  fs.writeFileSync(outputFile, output, "utf8")

  console.log(`✅ Wygenerowano: ${outputFile}`)
})
