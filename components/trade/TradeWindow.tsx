"use client"

import { Button } from "@/components/ui/8bit/button"
import { Badge } from "@/components/ui/badge"
import "@/components/ui/8bit/styles/retro.css"
import { cn } from "@/lib/utils"
import { ArrowLeftRight, Check, Handshake, X } from "lucide-react"
import { useCallback, useMemo, useState, type DragEvent } from "react"
import { TradeSidePanel } from "./TradeSidePanel"
import { TradeBoardState, TradeChangePayload, TradeItem, TradeParticipant } from "./types"
import { useTradeBoard } from "./useTradeBoard"
import styles from "./styles/TradeWindow.module.css"

export type TTradeWindowProps = {
  left: TradeParticipant
  right: TradeParticipant
  /** Which side belongs to the local player. Defaults to 1. */
  selfSide?: 1 | 2
  offerSlots?: number
  inventoryColumns?: number
  className?: string
  onChange?: (payload: TradeChangePayload) => void
  onAccept?: (payload: TradeChangePayload) => void
  onCancel?: () => void
}

export function TradeWindow({
  left,
  right,
  selfSide = 1,
  offerSlots = 6,
  inventoryColumns,
  className,
  onChange,
  onAccept,
  onCancel,
}: TTradeWindowProps) {
  const {
    board,
    totals,
    bothConfirmed,
    mime,
    placeItem,
    withdrawSlot,
    setSlotQuantity,
    setGold,
    toggleConfirm,
    accept,
    cancel,
    clearSide,
    parseDrop,
  } = useTradeBoard({ left, right, offerSlots, onChange, onAccept, onCancel })

  const [dropTarget, setDropTarget] = useState<{ side: 1 | 2; index: number } | null>(null)
  const [inventoryDropTarget, setInventoryDropTarget] = useState<1 | 2 | null>(null)

  const itemLookup = useMemo(() => {
    const map = new Map<number, TradeItem>()
    left.inventory.forEach((item) => map.set(item.id, item))
    right.inventory.forEach((item) => map.set(item.id, item))
    return map
  }, [left.inventory, right.inventory])

  const remainingBySide = useCallback(
    (side: 1 | 2): TradeItem[] => {
      const participant = side === 1 ? left : right
      const offered = board[side].slots

      return participant.inventory
        .map((item) => {
          const slot = offered.find((entry) => entry?.item.id === item.id)
          if (!slot) return item
          const quantity = item.quantity - slot.quantity
          return quantity > 0 ? { ...item, quantity } : null
        })
        .filter((item): item is TradeItem => item !== null)
    },
    [board, left, right],
  )

  const handleDragOverSlot = useCallback((event: DragEvent<HTMLDivElement>, side: 1 | 2, index: number) => {
    event.preventDefault()
    event.dataTransfer.dropEffect = "move"
    setDropTarget({ side, index })
  }, [])

  const handleDropOnSlot = useCallback(
    (event: DragEvent<HTMLDivElement>, side: 1 | 2, index: number) => {
      event.preventDefault()
      setDropTarget(null)

      const payload = parseDrop(event.dataTransfer)
      if (!payload) return

      const item = itemLookup.get(payload.itemId)
      if (!item) return

      if (payload.fromSlotIndex !== undefined) withdrawSlot(payload.side, payload.fromSlotIndex)

      placeItem(side, item, index)
    },
    [itemLookup, parseDrop, placeItem, withdrawSlot],
  )

  const handleDragOverInventory = useCallback((event: DragEvent<HTMLDivElement>, side: 1 | 2) => {
    event.preventDefault()
    event.dataTransfer.dropEffect = "move"
    setInventoryDropTarget(side)
  }, [])

  const handleDropOnInventory = useCallback(
    (event: DragEvent<HTMLDivElement>, side: 1 | 2) => {
      event.preventDefault()
      setInventoryDropTarget(null)

      const payload = parseDrop(event.dataTransfer)
      if (!payload || payload.fromSlotIndex === undefined) return

      withdrawSlot(payload.side, payload.fromSlotIndex)
    },
    [parseDrop, withdrawSlot],
  )

  const handleDragLeave = useCallback(() => setDropTarget(null), [])

  const handleItemClick = useCallback(
    (side: 1 | 2) => (item: TradeItem) => {
      if (side !== selfSide) return
      placeItem(side, item)
    },
    [placeItem, selfSide],
  )

  return (
    <div
      className={cn(styles.window, className)}
      data-testid='trade-window'
    >
      <header className={styles.header}>
        <div className={styles.title}>
          <ArrowLeftRight />
          <span className={cn("retro", styles.titleText)}>Trade</span>
        </div>

        <div className={styles.status}>
          {board[selfSide].confirmed ? (
            <Badge
              variant='outline'
              className={styles.statusBadge}
            >
              <Check /> Waiting for {selfSide === 1 ? right.name : left.name}
            </Badge>
          ) : (
            <Badge
              variant='secondary'
              className={styles.statusBadge}
            >
              Offer items or gold
            </Badge>
          )}
        </div>

        <Button
          variant='ghost'
          size='icon'
          onClick={cancel}
          aria-label='Close trade'
        >
          <X />
        </Button>
      </header>

      <div className={styles.body}>
        <TradeSidePanel
          participant={left}
          state={board[1]}
          side={1}
          selfSide={selfSide}
          remaining={remainingBySide(1)}
          totalValue={totals[1]}
          dropTargetIndex={dropTarget?.side === 1 ? dropTarget.index : null}
          inventoryDropTarget={inventoryDropTarget}
          inventoryColumns={inventoryColumns}
          mime={mime}
          onDropSlot={handleDropOnSlot}
          onDragOverSlot={handleDragOverSlot}
          onDragLeave={handleDragLeave}
          onWithdraw={withdrawSlot}
          onQuantityChange={setSlotQuantity}
          onDropInventory={handleDropOnInventory}
          onDragOverInventory={handleDragOverInventory}
          onItemClick={handleItemClick(1)}
          onGoldChange={setGold}
          onClear={clearSide}
        />

        <div
          className={styles.divider}
          aria-hidden='true'
        >
          <span className={cn("retro", styles.dividerText)}>VS</span>
        </div>

        <TradeSidePanel
          participant={right}
          state={board[2]}
          side={2}
          selfSide={selfSide}
          remaining={remainingBySide(2)}
          totalValue={totals[2]}
          dropTargetIndex={dropTarget?.side === 2 ? dropTarget.index : null}
          inventoryDropTarget={inventoryDropTarget}
          inventoryColumns={inventoryColumns}
          mime={mime}
          onDropSlot={handleDropOnSlot}
          onDragOverSlot={handleDragOverSlot}
          onDragLeave={handleDragLeave}
          onWithdraw={withdrawSlot}
          onQuantityChange={setSlotQuantity}
          onDropInventory={handleDropOnInventory}
          onDragOverInventory={handleDragOverInventory}
          onItemClick={handleItemClick(2)}
          onGoldChange={setGold}
          onClear={clearSide}
        />
      </div>

      <footer className={styles.footer}>
        <Button
          variant='ghost'
          onClick={cancel}
        >
          Cancel
        </Button>

        <div className={styles.footerActions}>
          <Button
            variant='outline'
            onClick={() => toggleConfirm(selfSide)}
            disabled={bothConfirmed}
          >
            {board[selfSide].confirmed ? <X /> : <Check />}
            {board[selfSide].confirmed ? "Unconfirm" : "Confirm offer"}
          </Button>

          <Button
            onClick={accept}
            disabled={!bothConfirmed}
          >
            <Handshake />
            {bothConfirmed ? "Accept trade" : "Awaiting confirmation"}
          </Button>
        </div>
      </footer>
    </div>
  )
}

export type { TradeBoardState, TradeParticipant, TradeItem }
export default TradeWindow
