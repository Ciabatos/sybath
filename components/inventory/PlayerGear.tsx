"use client"

import { GearSection } from "@/components/inventory/GearSection"
import { TInventorySlot } from "@/components/inventory/InventorySlot"
import { usePlayerGearInventory } from "@/methods/hooks/inventory/composite/usePlayerGearInventory"

type TProps = {
  selected?: TInventorySlot | null
  onSelect?: (slot: TInventorySlot) => void
}

export function PlayerGear({ selected, onSelect }: TProps) {
  const { combinedPlayerGearInventory } = usePlayerGearInventory()

  return (
    <GearSection
      slots={combinedPlayerGearInventory}
      selected={selected}
      onSelect={onSelect}
    />
  )
}