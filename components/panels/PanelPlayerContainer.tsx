"use client"

import { InventorySlot } from "@/components/inventory/InventorySlot"
import { usePlayerInventory } from "@/methods/hooks/inventory/composite/usePlayerInventory"
import styles from "./styles/PanelPlayerContainer.module.css"

export function PanelPlayerContainer() {
  const { combinedPlayerInventory } = usePlayerInventory()

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
          Przedmioty: {combinedPlayerInventory.filter((item) => item.itemId).length}/{combinedPlayerInventory.length}
        </span>
      </div>

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
