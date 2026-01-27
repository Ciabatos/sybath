"use client"

import { InventorySlot } from "@/components/panels/InventorySlot"
import { usePlayerInventory } from "@/methods/hooks/inventory/composite/usePlayerInventory"
import { DragDropProvider } from "@dnd-kit/react"
import styles from "./styles/PanelPlayerContainer.module.css"

export function PanelPlayerContainer() {
  const { combinedPlayerInventory } = usePlayerInventory()

  function handleDragEnd(event: any) {
    const { operation } = event
    const source = operation?.source
    const target = operation?.target

    if (!target) return
    const sourceData = source.data
    const targetData = target.data

    console.log(sourceData, targetData)
    if (!sourceData?.itemId) return

    if (targetData?.itemId) {
      console.log(`Items swapped between slot ${sourceData.id} and slot ${targetData.id}`)
    } else {
      console.log(`Item moved from slot ${sourceData.id} to slot ${targetData.id}`)
    }
  }

  const handleSortInventory = () => {
    console.log("Sorting inventory...")
  }

  return (
    <DragDropProvider onDragEnd={handleDragEnd}>
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
    </DragDropProvider>
  )
}
