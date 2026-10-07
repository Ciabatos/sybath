"use client"

import { InventoryInspector } from "@/components/inventory/InventoryInspector"
import { InventorySection } from "@/components/inventory/InventorySection"
import { TInventorySlot } from "@/components/inventory/InventorySlot"
import { BAG_SECTION } from "@/components/inventory/inventoryLayout"
import { useOtherPlayerInventory } from "@/methods/hooks/inventory/composite/useOtherPlayerInventory"
import { useState } from "react"
import styles from "./styles/PlayerContainer.module.css"

export function OtherPlayerContainer() {
  const { combinedOtherPlayerInventory } = useOtherPlayerInventory()
  const [selectedSlot, setSelectedSlot] = useState<TInventorySlot | null>(null)

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