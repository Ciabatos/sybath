"use client"

import { cn } from "@/lib/utils"
import { Package } from "lucide-react"
import type { DragEvent } from "react"
import { TradeItem } from "./types"
import styles from "./styles/TradeInventoryGrid.module.css"

type TProps = {
  items: TradeItem[]
  side: 1 | 2
  readOnly?: boolean
  mime: string
  onDragOver?: (event: DragEvent<HTMLDivElement>, side: 1 | 2) => void
  onDropItem?: (event: DragEvent<HTMLDivElement>, side: 1 | 2) => void
  onItemClick?: (item: TradeItem) => void
  isDropTarget?: boolean
  columns?: number
}

export function TradeInventoryGrid({
  items,
  side,
  readOnly,
  mime,
  onDragOver,
  onDropItem,
  onItemClick,
  isDropTarget,
  columns = 5,
}: TProps) {
  return (
    <div
      data-trade-inventory={side}
      className={cn(styles.grid, isDropTarget && styles.dropTarget)}
      style={{ gridTemplateColumns: `repeat(${columns}, minmax(0, 1fr))` }}
      onDragOver={(event) => onDragOver?.(event, side)}
      onDrop={(event) => onDropItem?.(event, side)}
    >
      {items.map((item) => (
        <div
          key={item.id}
          draggable={!readOnly}
          onDragStart={(event) => {
            event.dataTransfer.setData(mime, JSON.stringify({ side, itemId: item.id }))
            event.dataTransfer.effectAllowed = "move"
          }}
          onClick={() => onItemClick?.(item)}
          title={item.description ?? item.name}
          data-rarity={item.rarity}
          className={cn(styles.cell, readOnly && styles.readOnly)}
        >
          <span className={styles.icon}>{item.icon ?? <Package />}</span>
          {item.quantity > 1 && <span className={styles.quantity}>{item.quantity}</span>}
        </div>
      ))}

      {items.length === 0 && <span className={styles.empty}>No items</span>}
    </div>
  )
}
