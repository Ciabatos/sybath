import { spawn } from "node:child_process"

export const formatWithPrettier = (paths) =>
  new Promise((resolve, reject) => {
    const child = spawn("npx", ["prettier", "--write", ...paths], {
      shell: true,
      stdio: "inherit",
    })
    child.on("error", reject)
    child.on("close", (code) =>
      code === 0 ? resolve("Prettier formatting complete") : reject(new Error(`Prettier exited with code ${code}`)),
    )
  })
