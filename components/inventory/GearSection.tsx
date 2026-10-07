"use client"

import { InventorySlot, TInventorySlot } from "@/components/inventory/InventorySlot"
import { GEAR_LAYOUT, GEAR_SECTION, GEAR_SLOT_TYPES } from "@/components/inventory/inventoryLayout"
import styles from "./styles/PlayerGear.module.css"

type TProps = {
  slots: TInventorySlot[]
  selected?: TInventorySlot | null
  onSelect?: (slot: TInventorySlot) => void
}

/** Wspólny układ ekwipunku (paper-doll) dla gracza i innych postaci. */
export function GearSection({ slots, selected, onSelect }: TProps) {
  const slotTypeIds = Object.values(GEAR_SLOT_TYPES)

  const equippedCount = slots.filter((slot) => slot.itemId && slotTypeIds.includes(slot.inventorySlotTypeId)).length

  return (
    <section className={styles.container}>
      <header className={styles.header}>
        <h3 className={styles.title}>{GEAR_SECTION.title}</h3>
        <span className={styles.counter}>
          {equippedCount} / {GEAR_SECTION.slotsTotal}
        </span>
      </header>

      <div className={styles.gearGrid}>
        {GEAR_LAYOUT.map((cell, index) => {
          if (!cell) {
            return (
              <div
                key={`gear-gap-${index}`}
                className={styles.gap}
                aria-hidden
              />
            )
          }

          const gear = slots.find((slot) => slot.inventorySlotTypeId === cell.slotTypeId)
          const isSelected = Boolean(
            gear && selected?.slotId === gear.slotId && selected?.containerId === gear.containerId,
          )

          return (
            <InventorySlot
              key={`gear-${cell.slotTypeId}-${index}`}
              inventory={gear}
              placeholderIcon={cell.icon}
              slotLabel={cell.label}
              selected={isSelected}
              onSelect={onSelect}
            />
          )
        })}
      </div>
    </section>
  )
}