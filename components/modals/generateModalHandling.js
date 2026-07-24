import fs from "fs"
import path from "path"

const modalsPath = path.resolve("./components/modals")
const outputPath = path.join(modalsPath, "ModalHandling.tsx")

const files = fs
  .readdirSync(modalsPath)
  .filter((file) => file.endsWith(".tsx") && file !== "ModalHandling.tsx")
  .sort()

const imports = files
  .map((file) => {
    const componentName = file.replace(".tsx", "")

    return `import ${componentName} from "@/components/modals/${componentName}"`
  })
  .join("\n")

const components = files
  .map((file) => {
    const componentName = file.replace(".tsx", "")

    return `      <${componentName} />`
  })
  .join("\n")

const content = `"use client"

${imports}
import { useInventoryMonitor } from "@/methods/hooks/inventory/composite/useInventoryMonitor"

export default function ModalHandling() {
  useInventoryMonitor()

  return (
    <>
${components}
    </>
  )
}
`

fs.writeFileSync(outputPath, content, "utf8")

console.log("✅ Generated ModalHandling.tsx")
