import fs from "fs"
import path from "path"
const ROOT = path.resolve("./")

export default function createPanels(plop) {
  plop.setGenerator("createPanels", {
    description: "Sync LeftTopBar panels from folders to index files",

    prompts: [],

    actions: function () {
      const panelsDir = path.join(ROOT, "/components/panels")

      const files = fs.readdirSync(panelsDir, { withFileTypes: true })

      const panelFolders = files
        .filter((dirent) => dirent.isDirectory() && dirent.name !== "styles")
        .map((dirent) => {
          return {
            folderName: dirent.name,
          }
        })

      for (let folder of panelFolders) {
        const subFolderDir = path.join(panelsDir, `/${folder.folderName}`)
        const files = fs.readdirSync(subFolderDir, { withFileTypes: true })

        const panelFiles = files
          .filter((dirent) => dirent.isFile() && (dirent.name.endsWith(".tsx") || dirent.name.endsWith(".jsx")))
          .map((dirent) => {
            const fileName = path.basename(dirent.name, path.extname(dirent.name))
            return {
              folderName: folder.folderName,
              fileName: fileName,
            }
          })

        console.log(`Folder ${folder.folderName}:`, panelFiles)
      }

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
