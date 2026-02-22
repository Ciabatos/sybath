"use client"

import { InventorySlot } from "@/components/inventory/InventorySlot"
import { useOtherPlayerInventory } from "@/methods/hooks/inventory/composite/useOtherPlayerInventory"
import styles from "./styles/PlayerContainer.module.css"

export function OtherPlayerContainer() {
  const { combinedOtherPlayerInventory } = useOtherPlayerInventory()

  return (
    <div className={styles.container}>
      <div className={styles.toolbar}>
        <button
          className={styles.sortButton}
          title='Sortuj przedmioty'
        >
          🔄 Sortuj
        </button>
        <span className={styles.stats}>
          Przedmioty: {combinedOtherPlayerInventory.filter((item) => item.itemId).length}/
          {combinedOtherPlayerInventory.length}
        </span>
      </div>

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
