import { FlatCompat } from "@eslint/eslintrc"
import { dirname } from "path"
import { fileURLToPath } from "url"

const __filename = fileURLToPath(import.meta.url)
const __dirname = dirname(__filename)

const compat = new FlatCompat({
  baseDirectory: __dirname,
})

const eslintConfig = [
  ...compat.extends("next/core-web-vitals", "next/typescript"),

  // ✅ Scalona reguła: zakazy importów z core/* oraz actions/* w jednym miejscu
  {
    files: ["**/*.{js,jsx,ts,tsx}"],
    rules: {
      "no-restricted-imports": [
        "error",
        {
          patterns: [
            {
              group: ["@/methods/hooks/*/core", "@/methods/hooks/*/core/*"],
              message: "Importy z methods/hooks/*/core są dozwolone tylko wewnątrz odpowiadających folderów composite.",
            },
            {
              group: ["@/methods/actions", "@/methods/actions/*", "@/methods/actions/**/*"],
              message:
                "Importy z methods/actions są dozwolone tylko wewnątrz odpowiadających folderów composite hooków.",
            },
          ],
        },
      ],
    },
  },

  // ✅ Wyjątek: composite/* może importować z core/* (bez zmian)
  {
    files: ["methods/hooks/*/composite/**/*.{js,jsx,ts,tsx}"],
    rules: {
      "no-restricted-imports": "off",
    },
  },
]

export default eslintConfig
