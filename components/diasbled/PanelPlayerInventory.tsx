"use client"

import Inventory from "@/components/ui/custom/Inventory"
import { useFetchPlayerInventorySlots } from "@/methods/hooks/playerInventory/core/useFetchPlayerInventorySlots"

export default function PanelPlayerInventory() {
  const { playerInventorySlots } = useFetchPlayerInventorySlots()

  return <Inventory inventorySlots={playerInventorySlots}></Inventory>
}
