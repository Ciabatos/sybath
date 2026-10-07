"use client"

import { GearSection } from "@/components/inventory/GearSection"
import { TInventorySlot } from "@/components/inventory/InventorySlot"
import { useOtherPlayerGearInventory } from "@/methods/hooks/inventory/composite/useOtherPlayerGearInventory"

type TProps = {
  selected?: TInventorySlot | null
  onSelect?: (slot: TInventorySlot) => void
}

export function OtherPlayerGear({ selected, onSelect }: TProps) {
  const { combinedOtherPlayerGearInventory } = useOtherPlayerGearInventory()

  return (
    <GearSection
      slots={combinedOtherPlayerGearInventory}
      selected={selected}
      onSelect={onSelect}
    />
  )
}