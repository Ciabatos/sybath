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
      <InventorySlot
        key={gear?.slotId ?? `placeholder-${inventorySlotTypeId}`}
        inventory={gear}
        placeholderIcon={icon}
      />
    )
  }

  return (
    <div className={styles.container}>
      <div className={styles.header}>
        <h3 className={styles.title}>Equipment</h3>
      </div>

      <div className={styles.gearGrid}>
        {/* Row 1: Head, Neck — empty cell for alignment */}
        <div className={styles.gearRow}>
          {renderSlot(14, "GiCrestedHelmet")}
          {renderSlot(2, "GiEmeraldNecklace")}
          <div className={styles.emptyCell} />
        </div>

        {/* Row 2: Left hand, Chest, Right hand */}
        <div className={styles.gearRow}>
          {renderSlot(3, "Gloves")}
          {renderSlot(5, "GiChestArmor")}
          {renderSlot(4, "Gloves")}
        </div>

        {/* Row 3: Left weapon, empty, Right weapon/shield */}
        <div className={styles.gearRow}>
          {renderSlot(12, "GiDropWeapon")}
          <div className={styles.emptyCell} />
          {renderSlot(13, "HeavyShield")}
        </div>

        {/* Row 4: Rings */}
        <div className={styles.gearRow}>
          {renderSlot(9, "GiBigDiamondRing")}
          <div className={styles.emptyCell} />
          {renderSlot(10, "GiBigDiamondRing")}
        </div>

        {/* Row 5: Belts */}
        <div className={styles.gearRow}>
          {renderSlot(7, "GiBelt")}
          {renderSlot(6, "GiBelt")}
          {renderSlot(8, "GiBelt")}
        </div>

        {/* Row 6: Feet */}
        <div className={styles.gearRow}>
          <div className={styles.emptyCell} />
          {renderSlot(11, "GiSteeltoeBoots")}
          <div className={styles.emptyCell} />
        </div>
      </div>
    </div>
  )
}
