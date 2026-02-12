"use client"

import { InventorySlot } from "@/components/inventory/InventorySlot"
import { usePlayerGearInventory } from "@/methods/hooks/inventory/composite/usePlayerGearInventory"
import styles from "./styles/PanelPlayerGear.module.css"

export function PanelPlayerGear() {
  const { combinedPlayerGearInventory } = usePlayerGearInventory()

  const renderSlot = (inventorySlotTypeId: number, icon: string) => {
    const gear = Object.values(combinedPlayerGearInventory).find(
      (gearItem) => gearItem.inventorySlotTypeId === inventorySlotTypeId,
    )

    return (
      <div
        className={`${styles.slot} ${gear ? styles.slotFilled : ""}`}
        title={gear?.description || `Empty slot`}
      >
        <>
          <InventorySlot
            key={gear?.slotId}
            inventory={gear}
            placeholderIcon={icon}
          />
        </>
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
        <div className={styles.rowTop}>{renderSlot(14, "Helmet")}</div>

        {/* 2	Neck */}
        <div className={styles.rowAccessories}>{renderSlot(2, "Necklace")}</div>

        {/* 3	Left hand 
        9	Left finger 
        10	Right finger
        4	Right hand 
        */}
        <div className={styles.rowAccessories}>
          {renderSlot(3, "Gloves")}
          {renderSlot(9, "Ring")}
          {renderSlot(10, "Ring")}
          {renderSlot(4, "Gloves")}
        </div>

        {/* 12	Left hand gear
         5	Chest
         13	Right hand gear*/}
        <div className={styles.rowMiddle}>
          {renderSlot(12, "SwordMastery")}
          {renderSlot(5, "Armour")}
          {renderSlot(13, "HeavyShield")}
        </div>

        {/* 7	Left waist 
        6	Waist 
        8	Right waist*/}
        <div className={styles.rowMiddle}>
          <div className={styles.rowBelt}>{renderSlot(7, "Belt")}</div>
          <div className={styles.rowBelt}>{renderSlot(6, "Belt")}</div>
          <div className={styles.rowBelt}>{renderSlot(8, "Belt")}</div>
        </div>

        {/* 11	Feets*/}
        <div className={styles.rowBottom}>{renderSlot(11, "Boots")}</div>
      </div>
    </div>
  )
}
