"use client"

import { InventorySlot } from "@/components/panels/InventorySlot"
import { usePlayerInventory } from "@/methods/hooks/inventory/composite/usePlayerInventory"
import styles from "./styles/PanelPlayerContainer.module.css"

export function PanelPlayerContainer() {
  const { combinedPlayerInventory } = usePlayerInventory()

  const handleSortInventory = () => {
    console.log("Sorting inventory...")
  }

  return (
    <div className={styles.container}>
      <div className={styles.toolbar}>
        <button
          className={styles.sortButton}
          onClick={handleSortInventory}
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
            playerInventory={playerInventory}
          />
        ))}
      </div>
    </div>
  )
}
