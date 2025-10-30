export const getTableActions = () => [
  // 1. Database schema file
  {
    type: "add",
    path: "db/postgresMainDatabase/schemas/{{schema}}/{{tableCamelName}}.tsx",
    templateFile: "plop-templates/dbGetTable.hbs",
    force: true,
  },

  // 2. API route
  {
    type: "add",
    path: "app/api/{{table}}/route.tsx",
    templateFile: "plop-templates/apiGetTable.hbs",
    force: true,
  },

  // 3. React hook
  {
    type: "add",
    path: "methods/hooks/{{schema}}/core/useFetch{{tablePascalName}}.tsx",
    templateFile: "plop-templates/hookGetTable.hbs",
    force: true,
  },

  // 4. Server fetcher
  {
    type: "add",
    path: "methods/fetchers/{{schema}}/fetch{{tablePascalName}}Server.ts",
    templateFile: "plop-templates/hookGetTableServer.hbs",
    force: true,
  },

  // 5. Add import to atoms.ts
  {
    type: "modify",
    path: "store/atoms.ts",
    pattern: /((?:^"use client"\n)?(?:import[\s\S]*?\n))(?!import)/m,
    template:
      '$&import { {{typeName}}RecordBy{{typeRecordName}} } from "@/db/postgresMainDatabase/schemas/{{schema}}/{{tableCamelName}}"\n',
  },

  // 6. Add atom export
  {
    type: "modify",
    path: "store/atoms.ts",
    pattern: /(\/\/Tables\s*\n)/,
    template:
      "$1export const {{tableCamelName}}Atom = atom<{{typeName}}RecordBy{{typeRecordName}}>({})\n",
  },
]
