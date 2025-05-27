"use client"

import Inventory from "@/components/ui/custom/Inventory"
import { usePlayerInventorySlots } from "@/methods/hooks/playerInventory/usePlayerInventorySlots"

export default function PlayerInventory() {
  const { playerInventorySlots } = usePlayerInventorySlots()

  return <Inventory inventorySlots={playerInventorySlots}></Inventory>
}
