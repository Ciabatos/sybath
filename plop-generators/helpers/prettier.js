import { spawn } from "node:child_process"

export function formatWithPrettier(paths) {
  return new Promise((resolve, reject) => {
    const child = spawn("npx", ["prettier", "--write", ...paths], {
      shell: true, // konieczne na Windows!
      stdio: "inherit", // pokazuje output Prettiera
    })

    child.on("error", reject)

    child.on("close", (code) => {
      if (code === 0) {
        resolve("Prettier formatting complete")
      } else {
        reject(new Error(`Prettier exited with code ${code}`))
      }
    })
  })
}
