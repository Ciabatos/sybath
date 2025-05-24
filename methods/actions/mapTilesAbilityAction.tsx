"use server"

import { TJoinedMapTile } from "@/methods/functions/joinMapTiles"

export async function mapTilesAbilityAction(abilityId: number, clickedTile: TJoinedMapTile) {
  try {
  } catch (error) {
    console.error("Error validateAbilityAction :", error)
    // throw new Error("Failed to sing up")
    return "Failed to validateAbilityAction"
  }
}
