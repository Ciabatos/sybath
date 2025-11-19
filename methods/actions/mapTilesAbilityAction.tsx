"use server"

import { TJoinMap } from "@/methods/functions/map/joinMap"

export async function mapTilesAbilityAction(abilityId: number, clickedTile: TJoinMap) {
  try {
  } catch (error) {
    console.error("Error validateAbilityAction :", error)
    // throw new Error("Failed to sing up")
    return "Failed to validateAbilityAction"
  }
}
