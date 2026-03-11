"use client"

import { InventorySlot } from "@/components/inventory/InventorySlot"
import { usePlayerGearInventory } from "@/methods/hooks/inventory/composite/usePlayerGearInventory"
import styles from "./styles/PlayerGear.module.css"

export function PlayerGear() {
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
        <InventorySlot
          key={gear?.slotId}
          inventory={gear}
          placeholderIcon={icon}
        />
      </div>
    )
  }

  return (
    <div className={styles.container}>
      <div className={styles.header}>
        <h3 className={styles.title}>Equipment</h3>
      </div>

      <div className={styles.gearGrid}>
        {/* Row 1: Head, Neck, Shoulders */}
        <div className={styles.gearRow}>
          {renderSlot(14, "Helmet")}
          {renderSlot(2, "Necklace")}
          <div></div>
        </div>

        {/* Row 2: Left/Right Hands, Chest, Rings */}
        <div className={styles.gearRow}>
          {renderSlot(3, "Gloves")}
          {renderSlot(5, "Armour")}
          {renderSlot(4, "Gloves")}
        </div>

        {/* Row 3: Weapons/Shields */}
        <div className={styles.gearRow}>
          {renderSlot(12, "SwordMastery")}
          <div></div>
          {renderSlot(13, "HeavyShield")}
        </div>

        {/* Row 4: Rings */}
        <div className={styles.gearRow}>
          {renderSlot(9, "Ring")}
          <div></div>
          {renderSlot(10, "Ring")}
        </div>

        {/* Row 5: Belts */}
        <div className={styles.gearRow}>
          {renderSlot(7, "Belt")}
          {renderSlot(6, "Belt")}
          {renderSlot(8, "Belt")}
        </div>

        {/* Row 6: Feet */}
        <div className={styles.gearRow}>
          <div></div>
          {renderSlot(11, "Boots")}
          <div></div>
        </div>
      </div>
    </div>
  )
}
