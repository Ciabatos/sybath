"use client"

import { useFetchPlayerInventorySlots } from "@/methods/hooks/playerInventory/useFetchPlayerInventorySlots"
import { playerInventorySlotsAtom } from "@/store/atoms"
import { useAtomValue } from "jotai"

export default function PlayerInventory() {
  useFetchPlayerInventorySlots()
  const playerInventorySlots = useAtomValue(playerInventorySlotsAtom)

  const maxRow = Math.max(...playerInventorySlots.map((slot) => slot.row), 0)
  const maxCol = Math.max(...playerInventorySlots.map((slot) => slot.col), 0)

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
      {playerInventorySlots.map((slot) => (
        <div
          key={`${slot.row}-${slot.col}`}
          className={`inventory-slot row-${slot.row} col-${slot.col}`}
          style={{
            backgroundColor: slot.item_id ? "lightred" : "lightcoral",
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
