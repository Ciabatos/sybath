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

const modules = import.meta.glob("./EPanelsRightCenter/*.ts")

const entries = Object.keys(modules).map((path) => {
  const name = path.match(/\.\/EPanelsRightCenter\/(.+)\.ts$/)![1]

  return [name, name] as const
})

export const EPanelsRightCenter = Object.fromEntries(entries) as {
  [K in (typeof entries)[number][0]]: K
}

export type EPanelsRightCenter = (typeof EPanelsRightCenter)[keyof typeof EPanelsRightCenter]
