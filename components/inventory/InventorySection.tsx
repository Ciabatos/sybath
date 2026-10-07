"use client"

import { InventorySlot, TInventorySlot } from "@/components/inventory/InventorySlot"
import { Backpack } from "lucide-react"
import styles from "./styles/InventorySection.module.css"

type TProps = {
  title: string
  hint: string
  emptyHint: string
  slots: TInventorySlot[]
  usedSlots: number
  totalUnits: number
  selected?: TInventorySlot | null
  onSelect?: (slot: TInventorySlot) => void
}

/** Wspólna sekcja listy przedmiotów — nagłówek, liczniki i siatka slotów. */
export function InventorySection({
  title,
  hint,
  emptyHint,
  slots,
  usedSlots,
  totalUnits,
  selected,
  onSelect,
}: TProps) {
  return (
    <section className={styles.section}>
      <header className={styles.header}>
        <h3 className={styles.title}>{title}</h3>
        <span className={styles.counter}>
          {usedSlots} / {slots.length} slots
        </span>
        <span className={styles.counter}>{totalUnits} items</span>
      </header>

      {slots.length === 0 ? (
        <div className={styles.empty}>
          <Backpack className={styles.emptyIcon} />
          <p className={styles.emptyText}>{emptyHint}</p>
        </div>
      ) : (
        <>
          <div className={styles.grid}>
            {slots.map((slot) => (
              <InventorySlot
                key={`${slot.containerId}-${slot.slotId}`}
                inventory={slot}
                selected={Boolean(
                  selected && selected.slotId === slot.slotId && selected.containerId === slot.containerId,
                )}
                onSelect={onSelect}
              />
            ))}
          </div>
          <p className={styles.hint}>{hint}</p>
        </>
      )}
    </section>
  )
}