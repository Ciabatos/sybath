export const getFunctionActions = () => [
  // 1. Database schema file
  {
    type: "add",
    path: "db/postgresMainDatabase/schemas/{{schema}}/{{methodCamelName}}.tsx",
    templateFile: "plop-templates/dbGetFunction.hbs",
    force: true,
  },

  // 2. API route
  {
    type: "add",
    path: "app/api/{{methodCamelName}}/route.tsx",
    templateFile: "plop-templates/apiGetFunction.hbs",
    force: true,
  },

  // 3. React hook
  {
    type: "add",
    path: "methods/hooks/{{schema}}/core/useFetch{{methodPascalName}}.tsx",
    templateFile: "plop-templates/hookGetFunction.hbs",
    force: true,
  },

  // 4. Server fetcher
  {
    type: "add",
    path: "methods/fetchers/{{schema}}/fetch{{methodPascalName}}Server.ts",
    templateFile: "plop-templates/fetchServerGetFunction.hbs",
    force: true,
  },

  // 5. Add import to atoms.ts
  {
    type: "modify",
    path: "store/atoms.ts",
    pattern: /((?:^"use client"\n)?(?:import[\s\S]*?\n))(?!import)/m,
    template:
      '$&import { T{{methodPascalName}}RecordBy{{typeRecordName}} } from "@/db/postgresMainDatabase/schemas/{{schema}}/{{methodCamelName}}"\n',
  },

  // 6. Add atom export
  {
    type: "modify",
    path: "store/atoms.ts",
    pattern: /(\/\/Functions\s*\n)/,
    template:
      "$1export const {{methodCamelName}}Atom = atom<T{{methodPascalName}}RecordBy{{typeRecordName}}>({})\n",
  },
]
