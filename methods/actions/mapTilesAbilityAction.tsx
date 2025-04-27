"use server"

import { TTileCoordinates } from "@/methods/hooks/useMapTileClick"

export async function mapTilesAbilityAction(abilityId: number, clickedTile: TTileCoordinates) {
  try {
  } catch (error) {
    console.error("Error validateAbilityAction :", error)
    // throw new Error("Failed to sing up")
    return "Failed to validateAbilityAction"
  }
}
