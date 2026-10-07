"use client"

import { InventorySection } from "@/components/inventory/InventorySection"
import { TInventorySlot } from "@/components/inventory/InventorySlot"
import { BAG_SECTION } from "@/components/inventory/inventoryLayout"
import { useOtherPlayerInventory } from "@/methods/hooks/inventory/composite/useOtherPlayerInventory"
import styles from "./styles/PlayerContainer.module.css"

type TProps = {
  selected?: TInventorySlot | null
  onSelect?: (slot: TInventorySlot) => void
}

export function OtherPlayerContainer({ selected, onSelect }: TProps) {
  const { combinedOtherPlayerInventory } = useOtherPlayerInventory()

  const usedSlots = combinedOtherPlayerInventory.filter((slot) => slot.itemId).length
  const totalUnits = combinedOtherPlayerInventory.reduce(
    (sum, slot) => (slot.itemId ? sum + (slot.quantity || 0) : sum),
    0,
  )

  return (
    <div className={styles.container}>
      <InventorySection
        title={BAG_SECTION.title}
        hint={BAG_SECTION.hint}
        emptyHint="This hero carries nothing"
        slots={combinedOtherPlayerInventory}
        usedSlots={usedSlots}
        totalUnits={totalUnits}
        selected={selected}
        onSelect={onSelect}
      />
    </div>
  )
}