import { dirname } from "path";
import { fileURLToPath } from "url";
import { FlatCompat } from "@eslint/eslintrc";

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);

const compat = new FlatCompat({
  baseDirectory: __dirname,
});

const eslintConfig = [
  ...compat.extends("next/core-web-vitals", "next/typescript"),


 // 🚫 Domyślnie: zakaz importów z core/*
  {
    files: ["**/*.{js,jsx,ts,tsx}"],
    rules: {
      "no-restricted-imports": [
        "error",
        {
          patterns: [
            {
              group: [
                "@/methods/hooks/*/core",
                "@/methods/hooks/*/core/*",
              ],
              message:
                "Importy z methods/hooks/*/core są dozwolone tylko wewnątrz odpowiadających folderów composite.",
            },
          ],
        },
      ],
    },
  },

  // ✅ Wyjątek: composite/* może importować z core/*
  {
    files: ["methods/hooks/*/composite/**/*.{js,jsx,ts,tsx}"],
    rules: {
      "no-restricted-imports": "off",
    },
  },
];

export default eslintConfig;
