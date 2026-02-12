import getIcon from "@/methods/functions/icons/getIcon"
import { useDraggable, useDroppable } from "@dnd-kit/react"
import { ReactNode, useId } from "react"
import styles from "./styles/InventorySlot.module.css"

export type TInventorySlot = {
  id: number
  name: string
  description?: string
  image: string
  slotId: number
  containerId: number
  inventoryContainerTypeId: number
  inventorySlotTypeId: number
  itemId: number
  quantity: number
}

type TProps = {
  inventory?: TInventorySlot
  placeholderIcon?: string
}

function DroppableSlot({
  id,
  children,
  inventory,
  placeholderIcon,
}: {
  id: string
  children: ReactNode
  inventory?: TInventorySlot
  placeholderIcon?: string
}) {
  const { ref, isDropTarget } = useDroppable({
    id,
    data: inventory,
  })

  return (
    <div
      ref={ref}
      className={`${styles.slot} ${isDropTarget ? styles.dragOver : ""}`}
    >
      {children || (
        <div>
          {placeholderIcon && getIcon(placeholderIcon)}
          {inventory && <span>{inventory.slotId}</span>}
        </div>
      )}
      {isDropTarget && !children && <div className={styles.dropHint}>↓</div>}
    </div>
  )
}

function DraggableItem({ id, inventory }: { id: string; inventory: TInventorySlot }) {
  const { ref, isDragging } = useDraggable({
    id,
    data: inventory,
  })

  return (
    <div
      ref={ref}
      className={`${styles.item} ${isDragging ? styles.dragging : ""}`}
    >
      <span className={styles.itemImage}>{getIcon(inventory.image)}</span>
      <span className={styles.itemName}>{inventory.name}</span>
      <span>{inventory.slotId}</span>
      {inventory.quantity && inventory.quantity >= 1 ? (
        <span className={styles.quantity}> x{inventory.quantity}</span>
      ) : null}
    </div>
  )
}

// Główny komponent InventorySlot używający oddzielnych komponentów
export function InventorySlot({ inventory, placeholderIcon }: TProps) {
  const hasItem = inventory?.itemId
  const uniqueId = useId()
  const slotId = `slot-${inventory?.containerId}-${inventory?.slotId}-${uniqueId}`

  return (
    <DroppableSlot
      id={slotId}
      inventory={inventory}
      placeholderIcon={placeholderIcon}
    >
      {hasItem && inventory && (
        <DraggableItem
          id={`item-${inventory.containerId}-${inventory.slotId}-${uniqueId}`}
          inventory={inventory}
        />
      )}
    </DroppableSlot>
  )
}
