// "use client"

// export enum EPanelsRightCenter {
//   Inactive = "Inactive",
//   AllSkills = "AllSkills",
//   MapTileDetail = "MapTileDetail",
//   OtherPlayerPanel = "OtherPlayerPanel",
//   AllAbilities = "AllAbilities",
//   Crafting = "Crafting",
// }

"use client"

const modules = import.meta.glob<{ default: string }>("./EPanelsRightCenter/*.ts", {
  eager: true,
  import: "default",
})
// modules = { "./Inactive.ts": "Inactive", "./AllSkills.ts": "AllSkills", ... }

// budujemy obiekt-enum z wartości plików
const entries = Object.entries(modules).map(([path, value]) => {
  const fileName = path.match(/\.\/(.+)\.ts$/)![1]
  return [fileName, value] as const
})

export const EPanelsRightCenter = Object.fromEntries(entries) as {
  [K in (typeof entries)[number][0]]: K
}

// typ odpowiadający "wartościom enuma"
export type EPanelsRightCenter = (typeof EPanelsRightCenter)[keyof typeof EPanelsRightCenter]
