"use client"

import { InventorySlot } from "@/components/inventory/InventorySlot"
import { useOtherPlayerInventory } from "@/methods/hooks/inventory/composite/useOtherPlayerInventory"
import styles from "./styles/PlayerContainer.module.css"

export function OtherPlayerContainer() {
  const { combinedOtherPlayerInventory } = useOtherPlayerInventory()

  return (
    <div className={styles.container}>
      <div className={styles.grid}>
        {combinedOtherPlayerInventory.map((playerInventory) => (
          <InventorySlot
            key={playerInventory.slotId}
            inventory={playerInventory}
          />
        ))}
      </div>
    </div>
  )
}
