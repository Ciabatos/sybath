import fs from "fs"
import path from "path"

const atomsPath = path.resolve("./store/atoms")
const barrelPath = path.join("./store", "atoms.ts")

const files = fs.readdirSync(atomsPath).filter((file) => file.endsWith(".ts"))

const exports = files
  .map((file) => {
    const content = fs.readFileSync(path.join(atomsPath, file), "utf8")

    const match = content.match(/export const (\w+Atom)/)

    if (!match) {
      return null
    }

    const atomName = match[1]
    const fileName = file.replace(".ts", "")

    return `export { ${atomName} } from "@/store/atoms/${fileName}"`
  })
  .filter(Boolean)

const result = `
// GENERATED CODE - DO NOT EDIT MANUALLY
${exports.join("\n")}
`

fs.writeFileSync(barrelPath, result, "utf8")

console.log(`Generated ${barrelPath}`)
