import fs from "fs"
import path from "path"

const panelsPath = path.resolve("./types/panels")

const folders = fs.readdirSync(panelsPath, { withFileTypes: true }).filter((dir) => dir.isDirectory())

folders.forEach((folder) => {
  const panelName = folder.name

  const enumName = "EPanels" + panelName.replace(/^panel/, "").replace(/([A-Z])/g, "$1")

  const folderPath = path.join(panelsPath, panelName)

  const txtFiles = fs.readdirSync(folderPath).filter((file) => file.endsWith(".txt"))

  const entries = txtFiles.map((file) => fs.readFileSync(path.join(folderPath, file), "utf8").trim())

  const output = `// GENERATED CODE - DO NOT EDIT MANUALLY

import dynamic from "next/dynamic"
import React from "react"
import { ${enumName} } from "@/types/enumeration/${enumName}"

export const ${panelName}: Record<${enumName}, React.ComponentType<any> | null> = {
  [${enumName}.Inactive]: null,
${entries
  .map(
    (e) => `  ${e}, {
    loading: () => <p>Ładowanie panelu gracza...</p>,
  })`,
  )
  .join(",\n")}
}
`

  const outputFile = path.join(panelsPath, `${panelName}.tsx`)

  fs.writeFileSync(outputFile, output, "utf8")

  console.log(`✅ Wygenerowano: ${outputFile}`)
})
