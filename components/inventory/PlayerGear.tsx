"use client"

import { GearSection } from "@/components/inventory/GearSection"
import { usePlayerGearInventory } from "@/methods/hooks/inventory/composite/usePlayerGearInventory"

export function PlayerGear() {
  const { combinedPlayerGearInventory } = usePlayerGearInventory()

  return <GearSection slots={combinedPlayerGearInventory} />
}