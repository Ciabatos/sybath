import fs from "fs"
import path from "path"

export const COMPONENTS_ROOT = path.resolve("components")
export const HOOKS_ROOT = path.resolve("methods/hooks")
export const ENUM_ROOT = path.resolve("types/enumeration")

export function listComponentsFolders() {
  if (!fs.existsSync(COMPONENTS_ROOT)) return []
  return fs.readdirSync(COMPONENTS_ROOT).filter((f) => fs.statSync(path.join(COMPONENTS_ROOT, f)).isDirectory())
}

export function listHookFolders() {
  if (!fs.existsSync(HOOKS_ROOT)) return []
  return fs.readdirSync(HOOKS_ROOT).filter((f) => fs.statSync(path.join(HOOKS_ROOT, f)).isDirectory())
}

export function listEnumerationFiles() {
  if (!fs.existsSync(ENUM_ROOT)) return []
  return fs.readdirSync(ENUM_ROOT).filter((f) => {
    const abs = path.join(ENUM_ROOT, f)
    return fs.statSync(abs).isFile() && f !== "generateEnumerationHandling.js"
  })
}
