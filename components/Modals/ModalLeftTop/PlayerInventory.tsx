"use client"

import { useFetchInventorySlots } from "@/methods/hooks/playerInventory/useFetchInventorySlot"
import { inventorySlotsAtom } from "@/store/atoms"
import { useAtomValue } from "jotai"

export default function PlayerInventory() {
  useFetchInventorySlots()
  const inventorySlots = useAtomValue(inventorySlotsAtom)

  const maxRow = Math.max(...inventorySlots.map((slot) => slot.row), 0)
  const maxCol = Math.max(...inventorySlots.map((slot) => slot.col), 0)

  return (
    <div
      className="inventory-grid"
      style={{
        display: "grid",
        gridTemplateRows: `repeat(${maxRow}, 1fr)`,
        gridTemplateColumns: `repeat(${maxCol}, 1fr)`,
        gap: "8px",
        width: "100%",
        aspectRatio: `${maxCol} / ${maxRow}`,
      }}>
      {inventorySlots.map((slot) => (
        <div
          key={`${slot.row}-${slot.col}`}
          className={`inventory-slot row-${slot.row} col-${slot.col}`}
          style={{
            backgroundColor: slot.item_id ? "lightblue" : "lightgray",
            display: "flex",
            alignItems: "center",
            justifyContent: "center",
            border: "1px solid #ccc",
            borderRadius: "4px",
            minHeight: "50px",
          }}>
          {slot.item_id ? `Item ID: ${slot.item_id}` : "Empty"}
        </div>
      ))}
    </div>
  )
}
