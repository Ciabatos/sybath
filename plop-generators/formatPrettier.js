// Generator plop
export default function formatPrettier(plop) {
  const generatorName = "formatPrettier"
  plop.setGenerator(generatorName, {
    description: "Format code with Prettier",

    prompts: async (inquirer) => {},

    actions: [
      {
        type: "PrettierFormat",
      },
    ],
  })
}
