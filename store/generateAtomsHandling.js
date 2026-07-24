import fs from "fs"
import path from "path"

const atomsPath = path.resolve("./store/atoms")
const barrelPath = path.resolve("./store/atoms.ts")

function getAllTsFiles(dir) {
  const entries = fs.readdirSync(dir, {
    withFileTypes: true,
  })

  return entries.flatMap((entry) => {
    const fullPath = path.join(dir, entry.name)

    if (entry.isDirectory()) {
      return getAllTsFiles(fullPath)
    }

    if (entry.isFile() && entry.name.endsWith(".ts")) {
      return [fullPath]
    }

    return []
  })
}

const files = getAllTsFiles(atomsPath)

const exports = files
  .map((filePath) => {
    const content = fs.readFileSync(filePath, "utf8")

    const match = content.match(/export const (\w+Atom)/)

    if (!match) {
      return null
    }

    const atomName = match[1]

    const relativePath = path.relative(atomsPath, filePath).replace(".ts", "").replaceAll("\\", "/")

    return `export { ${atomName} } from "@/store/atoms/${relativePath}"`
  })
  .filter(Boolean)

const result = 
`// GENERATED CODE - DO NOT EDIT MANUALLY

${exports.join("\n")}
`

fs.writeFileSync(barrelPath, result, "utf8")

console.log(`✅ Generated atoms.ts (${exports.length} atoms)`)
