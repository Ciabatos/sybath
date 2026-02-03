"use client"

import { InventorySlot } from "@/components/panels/InventorySlot"
import { usePlayerGearInventory } from "@/methods/hooks/inventory/composite/usePlayerGearInventory"
import styles from "./styles/PanelPlayerGear.module.css"

interface GearItem {
  id: string
  name: string
  image: string
  description?: string
  stats?: string
}

export function PanelPlayerGear() {
  const { combinedPlayerGearInventory, moveOrSwapItem } = usePlayerGearInventory()

  const renderSlot = (inventorySlotTypeId: number, icon: string) => {
    const gear = Object.values(combinedPlayerGearInventory).find(
      (gearItem) => gearItem.inventorySlotTypeId === inventorySlotTypeId,
    )

    return (
      <div
        className={`${styles.slot} ${gear ? styles.slotFilled : ""}`}
        title={gear?.description || `Empty slot`}
      >
        {gear ? (
          <>
            <InventorySlot
              key={gear.slotId}
              inventory={gear}
            />
          </>
        ) : (
          <>null</>
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
        {/* 1	Head */}
        <div className={styles.rowTop}>{renderSlot(1, "⛑")}</div>

        {/* 2	Neck */}
        <div className={styles.rowAccessories}>{renderSlot(2, "📿")}</div>

        {/* 3	Left hand 
        9	Left finger 
        10	Right finger
        4	Right hand 
        */}
        <div className={styles.rowAccessories}>
          {renderSlot(3, "🧤")}
          {renderSlot(9, "💍")}
          {renderSlot(10, "💍")}
          {renderSlot(4, "🧤")}
        </div>

        {/* 12	Left hand gear
         5	Chest
         13	Right hand gear*/}
        <div className={styles.rowMiddle}>
          {renderSlot(12, "⚔")}
          {renderSlot(5, "🎒")}
          {renderSlot(13, "🛡")}
        </div>

        {/* 7	Left waist 
        6	Waist 
        8	Right waist*/}
        <div className={styles.rowMiddle}>
          <div className={styles.rowBelt}>{renderSlot(7, "🎒")}</div>
          <div className={styles.rowBelt}>{renderSlot(6, "🎒")}</div>
          <div className={styles.rowBelt}>{renderSlot(8, "🎒")}</div>
        </div>

        {/* 11	Feets*/}
        <div className={styles.rowBottom}>{renderSlot(11, "👢")}</div>
      </div>
    </div>
  )
}
