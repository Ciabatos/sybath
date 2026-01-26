"use client"

import getIcon from "@/methods/functions/icons/getIcon"
import { usePlayerInventory } from "@/methods/hooks/inventory/composite/usePlayerInventory"
import { useRef, useState } from "react"
import styles from "./styles/PanelPlayerContainer.module.css"

// Dummy actions - do zastąpienia rzeczywistymi akcjami
const dummyActions = {
  onDragEnd: (sourceSlotId: number | null, targetSlotId: number | null) => {
    console.log(`Drag ended: from ${sourceSlotId} to ${targetSlotId}`)
    // Tutaj można dodać logikę końca przeciągania
  },

  onDrop: (sourceSlotId: number, targetSlotId: number) => {
    console.log(`Item moved from slot ${sourceSlotId} to slot ${targetSlotId}`)
    // Tutaj można dodać logikę przenoszenia między slotami
    // Np. wywołanie API lub aktualizacja stanu
  },

  onSwap: (slotA: number, slotB: number) => {
    console.log(`Items swapped between slot ${slotA} and slot ${slotB}`)
    // Tutaj można dodać logikę zamiany przedmiotów
  },
}

export function PanelPlayerContainer() {
  const { combinedPlayerInventory } = usePlayerInventory()
  const [draggingSlotId, setDraggingSlotId] = useState<number | null>(null)
  const [dragOverSlotId, setDragOverSlotId] = useState<number | null>(null)
  const dragImageRef = useRef<HTMLDivElement>(null)

  const handleDragStart = (e: React.DragEvent, slotId: number, item: any) => {
    if (!item.itemId) return

    setDraggingSlotId(slotId)

    e.dataTransfer.setData("text/plain", slotId.toString())
    e.dataTransfer.effectAllowed = "move"

    // Utworzenie niestandardowego obrazka przeciągania
    if (dragImageRef.current) {
      dragImageRef.current.textContent = item.name
      dragImageRef.current.style.display = "block"
      e.dataTransfer.setDragImage(dragImageRef.current, 20, 20)
    }
  }

  const handleDragOver = (e: React.DragEvent, slotId: number) => {
    e.preventDefault()
    e.dataTransfer.dropEffect = "move"
    setDragOverSlotId(slotId)
  }

  const handleDragLeave = () => {
    setDragOverSlotId(null)
  }

  const handleDrop = (e: React.DragEvent, targetSlotId: number) => {
    e.preventDefault()
    const sourceSlotIdStr = e.dataTransfer.getData("text/plain")
    const sourceSlotId = Number(sourceSlotIdStr)

    if (isNaN(sourceSlotId) || sourceSlotId === targetSlotId) {
      setDragOverSlotId(null)
      return
    }

    // Znajdź przedmioty
    const sourceItem = combinedPlayerInventory.find((p) => p.slotId === sourceSlotId)
    const targetItem = combinedPlayerInventory.find((p) => p.slotId === targetSlotId)

    if (!sourceItem?.itemId) {
      setDragOverSlotId(null)
      return
    }

    // Wykonaj akcję w zależności od stanu slotu docelowego
    if (targetItem?.itemId) {
      // Zamiana przedmiotów
      dummyActions.onSwap(sourceSlotId, targetSlotId)

      // Tutaj dodaj logikę zamiany w stanie
      // Przykład:
      // const updatedInventory = combinedPlayerInventory.map(item => {
      //   if (item.slotId === sourceSlotId) return { ...item, ...targetItem, slotId: sourceSlotId }
      //   if (item.slotId === targetSlotId) return { ...item, ...sourceItem, slotId: targetSlotId }
      //   return item
      // })
      // updateInventory(updatedInventory)
    } else {
      // Przeniesienie do pustego slotu
      dummyActions.onDrop(sourceSlotId, targetSlotId)

      // Tutaj dodaj logikę przenoszenia w stanie
      // Przykład:
      // const updatedInventory = combinedPlayerInventory.map(item => {
      //   if (item.slotId === sourceSlotId) return { ...item, slotId: targetSlotId }
      //   if (item.slotId === targetSlotId) return { ...item, slotId: sourceSlotId, ...sourceItem }
      //   return item
      // })
      // updateInventory(updatedInventory)
    }

    setDragOverSlotId(null)
  }

  const handleDragEnd = () => {
    setDraggingSlotId(null)
    setDragOverSlotId(null)
  }

  const handleDoubleClick = (slotId: number, item: any) => {
    if (!item.itemId) return

    console.log(`Context menu for item: ${item.name} in slot ${slotId}`)
  }

  const handleSortInventory = () => {
    console.log("Sorting inventory...")
    // Tutaj dodaj logikę sortowania
    // Przykład:
    // const sortedInventory = [...combinedPlayerInventory].sort((a, b) => {
    //   if (!a.itemId && !b.itemId) return 0
    //   if (!a.itemId) return 1
    //   if (!b.itemId) return -1
    //   return a.name.localeCompare(b.name)
    // })
    // updateInventory(sortedInventory)
  }

  return (
    <>
      {/* Niewidzialny element dla obrazka przeciągania */}
      <div
        ref={dragImageRef}
        style={{
          position: "absolute",
          top: -1000,
          left: -1000,
          background: "rgba(0, 0, 0, 0.8)",
          color: "white",
          padding: "4px 8px",
          borderRadius: "4px",
          pointerEvents: "none",
          display: "none",
          zIndex: 9999,
        }}
      />

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
          {combinedPlayerInventory.map((playerInventory) => {
            const isDragging = draggingSlotId === playerInventory.slotId
            const isDragOver = dragOverSlotId === playerInventory.slotId

            return (
              <div
                key={playerInventory.slotId}
                className={` ${styles.slot} ${playerInventory.itemId ? styles.occupied : ""} ${isDragging ? styles.dragging : ""} ${isDragOver ? styles.dragOver : ""} `}
                title={
                  playerInventory.itemId
                    ? `${playerInventory.name}${playerInventory.description ? `\n${playerInventory.description}` : ""}`
                    : "Empty slot"
                }
                draggable={!!playerInventory.itemId}
                onDragStart={(e) => handleDragStart(e, playerInventory.slotId, playerInventory)}
                onDragOver={(e) => handleDragOver(e, playerInventory.slotId)}
                onDragLeave={handleDragLeave}
                onDrop={(e) => handleDrop(e, playerInventory.slotId)}
                onDragEnd={handleDragEnd}
                onDoubleClick={() => handleDoubleClick(playerInventory.slotId, playerInventory)}
              >
                {playerInventory.itemId ? (
                  <div className={styles.item}>
                    <span className={styles.itemImage}>{getIcon(playerInventory.image)}</span>
                    <span className={styles.itemName}>{playerInventory.name}</span>
                    {playerInventory.quantity && playerInventory.quantity >= 1 ? (
                      <span className={styles.quantity}> x{playerInventory.quantity}</span>
                    ) : null}
                  </div>
                ) : (
                  isDragOver && draggingSlotId && <div className={styles.dropHint}>↓</div>
                )}
                {/* <div className={styles.slotNumber}>{playerInventory.slotId}</div> */}
              </div>
            )
          })}
        </div>
      </div>
    </>
  )
}
