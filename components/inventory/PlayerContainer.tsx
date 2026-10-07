"use client"

import { InventoryInspector } from "@/components/inventory/InventoryInspector"
import { InventorySection } from "@/components/inventory/InventorySection"
import { TInventorySlot } from "@/components/inventory/InventorySlot"
import { BAG_SECTION } from "@/components/inventory/inventoryLayout"
import { usePlayerInventory } from "@/methods/hooks/inventory/composite/usePlayerInventory"
import { useState } from "react"
import styles from "./styles/PlayerContainer.module.css"

export function PlayerContainer() {
  const { combinedPlayerInventory } = usePlayerInventory()
  const [selectedSlot, setSelectedSlot] = useState<TInventorySlot | null>(null)

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
        selected={selectedSlot}
        onSelect={setSelectedSlot}
      />
      <InventoryInspector
        slot={selectedSlot}
        emptyHint='Select an item to read its description'
      />
    </div>
  )
}