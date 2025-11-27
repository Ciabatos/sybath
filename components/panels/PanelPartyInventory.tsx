"use client"

import { useFetchPlayerInventorySlots } from "@/methods/hooks/playerInventory/core/useFetchPlayerInventorySlots"

export default function PanelPartyInventory() {
  const { playerInventorySlots } = useFetchPlayerInventorySlots()

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
