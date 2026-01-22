import fs from "fs"
import path from "path"
const ROOT = path.resolve("./")

export default function createPanels(plop) {
  plop.setGenerator("createPanels", {
    description: "Sync LeftTopBar panels from folders to index files",

    prompts: [],

    actions: function () {
      const panelsDir = path.join(ROOT, "/components/panels/LeftTopBar")

      const panelFolders = fs
        .readdirSync(panelsDir, { withFileTypes: true })
        .filter((dirent) => dirent.isDirectory())
        .map((dirent) => ({
          folderName: dirent.name,
          enumName: dirent.name, // To samo co folderName
          componentName: dirent.name, // To samo co folderName
        }))

      console.log(panelFolders.map((p) => p.folderName))

      return [
        // {
        //   type: "add",
        //   path: "../src/components/panels/panelLeftTopBar.ts",
        //   templateFile: "plop-templates/panelLeftTopBar.hbs",
        //   force: true,
        //   data: { panels: panelFolders },
        // },
        // {
        //   type: "add",
        //   path: "../src/types/enumeration/EPanelsLeftTopBar.ts",
        //   templateFile: "plop-templates/EPanelsLeftTopBar.hbs",
        //   force: true,
        //   data: { panels: panelFolders },
        // },
      ]
    },
  })
}
