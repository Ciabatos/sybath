"use client"

import { InventorySection } from "@/components/inventory/InventorySection"
import { TInventorySlot } from "@/components/inventory/InventorySlot"
import { BAG_SECTION } from "@/components/inventory/inventoryLayout"
import { usePlayerInventory } from "@/methods/hooks/inventory/composite/usePlayerInventory"
import styles from "./styles/PlayerContainer.module.css"

type TProps = {
  selected?: TInventorySlot | null
  onSelect?: (slot: TInventorySlot) => void
}

export function PlayerContainer({ selected, onSelect }: TProps) {
  const { combinedPlayerInventory } = usePlayerInventory()

  const usedSlots = combinedPlayerInventory.filter((slot) => slot.itemId).length
  const totalUnits = combinedPlayerInventory.reduce(
    (sum, slot) => (slot.itemId ? sum + (slot.quantity || 0) : sum),
    0,
  )

  return (
    <div className={styles.container}>
      <InventorySection
        title={BAG_SECTION.title}
        hint={BAG_SECTION.hint}
        emptyHint={BAG_SECTION.emptyHint}
        slots={combinedPlayerInventory}
        usedSlots={usedSlots}
        totalUnits={totalUnits}
        selected={selected}
        onSelect={onSelect}
      />
    </div>
  )
}