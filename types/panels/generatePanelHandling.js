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

  const output = `import { ${enumName} } from "@/types/enumeration/${enumName}"
import React from "react"

export const ${panelName}: Record<
  ${enumName},
  React.LazyExoticComponent<React.ComponentType<any>> | null
> = {
  [${enumName}.Inactive]: null,
  [${enumName}.MovementPanel]: React.lazy(() => import("@/components/map/MovementPanel")),
${entries.map((e) => "  " + e).join(",\n")}
}
`

  fs.writeFileSync(path.join(panelsPath, `${panelName}.ts`), output, "utf8")

  console.log(`✅ Wygenerowano: ${outputFile}`)
})
