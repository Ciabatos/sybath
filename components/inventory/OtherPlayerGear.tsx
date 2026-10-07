"use client"

import { GearSection } from "@/components/inventory/GearSection"
import { useOtherPlayerGearInventory } from "@/methods/hooks/inventory/composite/useOtherPlayerGearInventory"

export function OtherPlayerGear() {
  const { combinedOtherPlayerGearInventory } = useOtherPlayerGearInventory()

  return <GearSection slots={combinedOtherPlayerGearInventory} />
}