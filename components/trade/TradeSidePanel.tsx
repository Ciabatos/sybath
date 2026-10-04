"use client"

import { Avatar, AvatarFallback, AvatarImage } from "@/components/ui/avatar"
import { Badge } from "@/components/ui/badge"
import { Button } from "@/components/ui/8bit/button"
import { cn } from "@/lib/utils"
import { Check, Coins, X } from "lucide-react"
import type { DragEvent } from "react"
import { TradeItem, TradeParticipant, TradeSideState } from "./types"
import { TradeInventoryGrid } from "./TradeInventoryGrid"
import { TradeSlotCell } from "./TradeSlotCell"
import styles from "./styles/TradeSidePanel.module.css"

type TProps = {
  participant: TradeParticipant
  state: TradeSideState
  side: 1 | 2
  remaining: TradeItem[]
  totalValue: number
  dropTargetIndex: number | null
  readOnly?: boolean
  selfSide?: 1 | 2
  mime: string
  onDropSlot: (event: DragEvent<HTMLDivElement>, side: 1 | 2, index: number) => void
  onDragOverSlot: (event: DragEvent<HTMLDivElement>, side: 1 | 2, index: number) => void
  onDragLeave: () => void
  onWithdraw: (side: 1 | 2, index: number) => void
  onQuantityChange: (side: 1 | 2, index: number, quantity: number) => void
  onDropInventory: (event: DragEvent<HTMLDivElement>, side: 1 | 2) => void
  onDragOverInventory: (event: DragEvent<HTMLDivElement>, side: 1 | 2) => void
  onItemClick: (item: TradeItem) => void
  onGoldChange: (side: 1 | 2, amount: number) => void
  onClear: (side: 1 | 2) => void
  inventoryDropTarget: 1 | 2 | null
  inventoryColumns?: number
}

export function TradeSidePanel({
  participant,
  state,
  side,
  remaining,
  totalValue,
  dropTargetIndex,
  readOnly,
  selfSide,
  mime,
  onDropSlot,
  onDragOverSlot,
  onDragLeave,
  onWithdraw,
  onQuantityChange,
  onDropInventory,
  onDragOverInventory,
  onItemClick,
  onGoldChange,
  onClear,
  inventoryDropTarget,
  inventoryColumns,
}: TProps) {
  const isSelf = selfSide === side
  const canEdit = !readOnly && isSelf
  const initials = participant.name.slice(0, 2).toUpperCase()

  return (
    <section
      data-side={side}
      data-self={isSelf}
      className={cn(styles.panel, isSelf ? styles.self : styles.other, state.confirmed && styles.confirmed)}
    >
      <header className={styles.header}>
        <Avatar
          size='lg'
          className={styles.avatar}
        >
          {participant.avatar && (
            <AvatarImage
              src={participant.avatar}
              alt={participant.name}
            />
          )}
          <AvatarFallback className={styles.avatarFallback}>{initials}</AvatarFallback>
        </Avatar>

        <div className={styles.identity}>
          <span className={styles.name}>{participant.name}</span>
          {participant.level !== undefined && <span className={styles.level}>Level {participant.level}</span>}
        </div>

        {state.confirmed && (
          <Badge
            variant='outline'
            className={styles.confirmBadge}
          >
            <Check /> Confirmed
          </Badge>
        )}
      </header>

      <div className={styles.section}>
        <div className={styles.sectionHeader}>
          <span className={cn("retro", styles.sectionTitle)}>Offering</span>
          <span className={styles.sectionMeta}>
            {state.slots.filter(Boolean).length}/{state.slots.length} slots
          </span>
        </div>

        <div className={styles.slots}>
          {state.slots.map((slot, index) => (
            <TradeSlotCell
              key={index}
              slot={slot}
              index={index}
              side={side}
              readOnly={!canEdit}
              isDropTarget={canEdit && dropTargetIndex === index}
              mime={mime}
              onDropItem={onDropSlot}
              onDragOver={onDragOverSlot}
              onDragLeave={onDragLeave}
              onWithdraw={onWithdraw}
              onQuantityChange={onQuantityChange}
            />
          ))}
        </div>

        <div className={styles.goldRow}>
          <label
            className={styles.goldLabel}
            htmlFor={`gold-${side}`}
          >
            <Coins /> Gold
          </label>
          <input
            id={`gold-${side}`}
            type='number'
            min={0}
            max={participant.gold}
            value={state.gold}
            disabled={!canEdit}
            onChange={(event) => onGoldChange(side, Number(event.target.value))}
            className={cn("retro", styles.goldInput)}
          />
          <span className={styles.goldMax}>/ {participant.gold}</span>
        </div>

        <div className={styles.footerRow}>
          <span className={styles.totalValue}>{totalValue} value</span>
          {canEdit && (
            <Button
              size='sm'
              variant='outline'
              onClick={() => onClear(side)}
              disabled={state.gold === 0 && state.slots.every((slot) => slot === null)}
            >
              <X /> Clear
            </Button>
          )}
        </div>
      </div>

      <div className={styles.section}>
        <div className={styles.sectionHeader}>
          <span className={cn("retro", styles.sectionTitle)}>{isSelf ? "Your inventory" : "Their inventory"}</span>
        </div>

        <TradeInventoryGrid
          items={remaining}
          side={side}
          readOnly={!canEdit}
          mime={mime}
          isDropTarget={canEdit && inventoryDropTarget === side}
          onDragOver={onDragOverInventory}
          onDropItem={onDropInventory}
          onItemClick={onItemClick}
          columns={inventoryColumns}
        />
      </div>
    </section>
  )
}
