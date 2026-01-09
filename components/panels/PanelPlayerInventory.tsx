"use client"

import { PanelPlayerGear } from "@/components/panels/PanelPlayerGear"
import styles from "@/components/panels/styles/PanelPlayerInventory.module.css"
import { useState } from "react"

interface InventoryItem {
  id: string
  name: string
  image: string
  width: number
  height: number
  x: number
  y: number
  description?: string
}

interface Props {
  columns?: number
  rows?: number
  items?: InventoryItem[]
}

export function PanelPlayerInventory({ columns = 1, rows = 22, items: initialItems = [] }: Props) {
  const [items, setItems] = useState<InventoryItem[]>(initialItems)
  const [draggedItem, setDraggedItem] = useState<InventoryItem | null>(null)
  const [hoveredSlot, setHoveredSlot] = useState<{ x: number; y: number } | null>(null)

  const handleDragStart = (item: InventoryItem) => {
    setDraggedItem(item)
  }

  const handleDragEnd = () => {
    setDraggedItem(null)
    setHoveredSlot(null)
  }

  const handleSlotDrop = (x: number, y: number) => {
    if (!draggedItem) return

    if (x + draggedItem.width > columns || y + draggedItem.height > rows) {
      return
    }

    setItems(items.map((item) => (item.id === draggedItem.id ? { ...item, x, y } : item)))
  }

  const isSlotOccupied = (x: number, y: number, excludeItemId?: string): boolean => {
    return items.some((item) => {
      if (excludeItemId && item.id === excludeItemId) return false
      return x >= item.x && x < item.x + item.width && y >= item.y && y < item.y + item.height
    })
  }

  const renderGrid = () => {
    const slots = []
    for (let row = 0; row < rows; row++) {
      for (let col = 0; col < columns; col++) {
        const isOccupied = isSlotOccupied(col, row)
        const isHovered = hoveredSlot?.x === col && hoveredSlot?.y === row

        slots.push(
          <div
            key={`${col}-${row}`}
            className={`${styles.slot} ${isOccupied ? styles.occupied : ""} ${isHovered ? styles.hovered : ""}`}
            onDragOver={(e) => {
              e.preventDefault()
              setHoveredSlot({ x: col, y: row })
            }}
            onDrop={() => handleSlotDrop(col, row)}
          />,
        )
      }
    }
    return slots
  }

  return (
    <div className={styles.wrapper}>
      <PanelPlayerGear />
      <div className={styles.container}>
        <div
          className={styles.grid}
          style={{
            gridTemplateColumns: `repeat(${4}, 1fr)`,
            gridTemplateRows: `repeat(${rows}, 1fr)`,
          }}
        >
          {renderGrid()}

          {items.map((item) => (
            <div
              key={item.id}
              className={styles.item}
              draggable
              onDragStart={() => handleDragStart(item)}
              onDragEnd={handleDragEnd}
              style={{
                gridColumn: `${item.x + 1} / span ${item.width}`,
                gridRow: `${item.y + 1} / span ${item.height}`,
              }}
              title={item.description}
            >
              <img
                src={item.image || "/placeholder.svg"}
                alt={item.name}
                className={styles.itemImage}
              />
              <span className={styles.itemName}>{item.name}</span>
            </div>
          ))}
        </div>
      </div>
    </div>
  )
}
