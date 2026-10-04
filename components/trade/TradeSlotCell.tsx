"use client"

import { cn } from "@/lib/utils"
import { Minus, Package, Plus } from "lucide-react"
import type { DragEvent } from "react"
import { TradeOfferSlot } from "./types"
import styles from "./styles/TradeSlotCell.module.css"

type TProps = {
  slot: TradeOfferSlot
  index: number
  side: 1 | 2
  readOnly?: boolean
  isDropTarget?: boolean
  mime: string
  onDropItem: (event: DragEvent<HTMLDivElement>, side: 1 | 2, index: number) => void
  onDragOver: (event: DragEvent<HTMLDivElement>, side: 1 | 2, index: number) => void
  onDragLeave: () => void
  onWithdraw: (side: 1 | 2, index: number) => void
  onQuantityChange: (side: 1 | 2, index: number, quantity: number) => void
}

export function TradeSlotCell({
  slot,
  index,
  side,
  readOnly,
  isDropTarget,
  mime,
  onDropItem,
  onDragOver,
  onDragLeave,
  onWithdraw,
  onQuantityChange,
}: TProps) {
  const max = slot ? (slot.item.maxStack ?? slot.item.quantity) : 1

  return (
    <div
      data-trade-slot={`${side}-${index}`}
      data-state={slot ? "filled" : "empty"}
      className={cn(styles.slot, isDropTarget && styles.dropTarget, readOnly && styles.readOnly)}
      onDragOver={(event) => onDragOver(event, side, index)}
      onDragLeave={onDragLeave}
      onDrop={(event) => onDropItem(event, side, index)}
    >
      {slot ? (
        <div
          draggable={!readOnly}
          onDragStart={(event) => {
            event.dataTransfer.setData(mime, JSON.stringify({ side, itemId: slot.item.id, fromSlotIndex: index }))
            event.dataTransfer.effectAllowed = "move"
          }}
          className={styles.item}
        >
          <span className={styles.itemIcon}>{slot.item.icon ?? <Package />}</span>
          <span className={styles.itemName}>{slot.item.name}</span>

          {slot.quantity > 1 && <span className={styles.quantity}>{slot.quantity}</span>}

          {!readOnly && max > 1 && (
            <div className={styles.stepper}>
              <button
                type='button'
                aria-label={`Decrease ${slot.item.name}`}
                onClick={() => onQuantityChange(side, index, slot.quantity - 1)}
                disabled={slot.quantity <= 1}
                className={styles.stepperButton}
              >
                <Minus />
              </button>
              <button
                type='button'
                aria-label={`Increase ${slot.item.name}`}
                onClick={() => onQuantityChange(side, index, slot.quantity + 1)}
                disabled={slot.quantity >= max}
                className={styles.stepperButton}
              >
                <Plus />
              </button>
            </div>
          )}

          {!readOnly && (
            <button
              type='button'
              aria-label={`Remove ${slot.item.name} from offer`}
              onClick={() => onWithdraw(side, index)}
              className={styles.remove}
            >
              ×
            </button>
          )}
        </div>
      ) : (
        <span className={styles.placeholder}>{readOnly ? null : "+"}</span>
      )}
    </div>
  )
}
