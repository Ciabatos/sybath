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
      <div className={styles.gearGrid}>
        {renderSlot(3, "Gloves")}
        {renderSlot(14, "GiCrestedHelmet")}
        {renderSlot(4, "Gloves")}
        {renderSlot(2, "GiEmeraldNecklace")}
        <div></div>
        {renderSlot(12, "GiDropWeapon")}
        {renderSlot(5, "GiChestArmor")}
        {renderSlot(13, "HeavyShield")}
        {renderSlot(9, "GiBigDiamondRing")}
        {renderSlot(10, "GiBigDiamondRing")}
        {renderSlot(6, "GiBelt")}
        {renderSlot(7, "GiBelt")}
        {renderSlot(8, "GiBelt")}

        {renderSlot(11, "GiSteeltoeBoots")}
        <div></div>
      </div>
    </div>
  )
}
