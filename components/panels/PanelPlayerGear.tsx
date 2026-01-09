"use client"

import styles from "@/components/panels/styles/PanelPlayerGear.module.css"
import { useState } from "react"

interface GearItem {
  id: string
  name: string
  image: string
  description?: string
  stats?: string
}

const defaultGear = {
  helm: null,
  weapon: null,
  shield: null,
  armor: null,
  boots: null,
  trinket: null,
  belt: null,
  ring1: null,
  ring2: null,
  beltSlot1: null,
  beltSlot2: null,
}

export function PanelPlayerGear() {
  const [gear, setGear] = useState<Record<string, GearItem | null>>(defaultGear)
  const [selectedSlot, setSelectedSlot] = useState<string | null>(null)

  const renderSlot = (slotName: string, label: string, icon: string) => {
    const item = gear[slotName]
    const isSelected = selectedSlot === slotName

    return (
      <div
        className={`${styles.slot} ${item ? styles.slotFilled : ""} ${isSelected ? styles.slotSelected : ""}`}
        title={item?.description || `Empty ${label} slot`}
      >
        {item ? (
          <>
            <img
              src={item.image || "/placeholder.svg"}
              alt={item.name}
              className={styles.slotImage}
            />
            <span className={styles.slotLabel}>{item.name}</span>
          </>
        ) : (
          <>
            <div className={styles.slotIcon}>{icon}</div>
            <span className={styles.slotLabel}>{label}</span>
          </>
        )}
      </div>
    )
  }

  return (
    <div className={styles.container}>
      <div className={styles.header}>
        <h3 className={styles.title}>Equipped Gear</h3>
      </div>

      <div className={styles.gearLayout}>
        {/* Top row: Helm */}
        <div className={styles.rowTop}>{renderSlot("helm", "Helm", "⛑")}</div>

        {/* Middle row: Weapon, Armor, Shield */}
        <div className={styles.rowMiddle}>
          {renderSlot("weapon", "Weapon", "⚔")}
          {renderSlot("armor", "Armor", "🛡")}
          {renderSlot("shield", "Shield", "🛡")}
        </div>

        {/* Accessories row: Ring1, Trinket, Ring2 */}
        <div className={styles.rowAccessories}>
          {renderSlot("ring1", "Ring", "💍")}
          {renderSlot("trinket", "Trinket", "✦")}
          {renderSlot("ring2", "Ring", "💍")}
        </div>

        {/* Belt row */}
        <div className={styles.rowBelt}>{renderSlot("belt", "Belt", "⚡")}</div>

        {/* Belt slots row */}
        <div className={styles.rowBeltSlots}>
          {renderSlot("beltSlot1", "Belt Slot", "🎒")}
          {renderSlot("beltSlot2", "Belt Slot", "🎒")}
        </div>

        {/* Bottom row: Boots */}
        <div className={styles.rowBottom}>{renderSlot("boots", "Boots", "👢")}</div>
      </div>
    </div>
  )
}
