"use client"

import { InventorySlot } from "@/components/inventory/InventorySlot"
import { usePlayerInventory } from "@/methods/hooks/inventory/composite/usePlayerInventory"
import styles from "./styles/PlayerContainer.module.css"

export function PlayerContainer() {
  const { combinedPlayerInventory } = usePlayerInventory()

  return (
    <div className={styles.container}>
      <div className={styles.grid}>
        {combinedPlayerInventory.map((playerInventory) => (
          <InventorySlot
            key={playerInventory.slotId}
            inventory={playerInventory}
          />
        ))}
      </div>
    </div>
  )
}
