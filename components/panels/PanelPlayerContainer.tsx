"use client"

import { usePlayerInventory } from "@/methods/hooks/inventory/composite/usePlayerInventory"
import styles from "./styles/PanelPlayerContainer.module.css"

export function PanelPlayerContainer() {
  const { combinedPlayerInventory } = usePlayerInventory()

  return (
    <div className={styles.container}>
      <div className={styles.grid}>
        {combinedPlayerInventory.map((playerInventory) => (
          <div
            key={playerInventory.slotId}
            className={`${styles.slot} ${playerInventory.itemId ? styles.occupied : ""}`}
            title={playerInventory.itemId ? playerInventory.name : "Empty slot"}
          >
            {playerInventory.itemId ? (
              <div
                className={styles.item}
                draggable
              >
                <img
                  className={styles.itemImage}
                  src={playerInventory.image}
                  alt={playerInventory.name}
                />
                <span className={styles.itemName}>{playerInventory.name}</span>
              </div>
            ) : null}
          </div>
        ))}
      </div>
    </div>
  )
}
