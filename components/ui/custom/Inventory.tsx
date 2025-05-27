import { TInventorySlots } from "@/db/postgresMainDatabase/schemas/items/inventories"

interface Props {
  inventorySlots: TInventorySlots[]
}

export default function Inventory({ inventorySlots }: Props) {
  console.log("Inventory component rendered with slots:", inventorySlots)
  if (!inventorySlots || inventorySlots.length === 0) {
    return <div className="inventory-grid">You dont have permission to see this inventory</div>
  }

  const maxRow = Math.max(...inventorySlots?.map((slot) => slot.row), 0)
  const maxCol = Math.max(...inventorySlots?.map((slot) => slot.col), 0)

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
      {inventorySlots?.map((slot) => (
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
          {slot.item_id ? `${slot.name}: ${slot.quantity}` : "Empty"}
        </div>
      ))}
    </div>
  )
}
