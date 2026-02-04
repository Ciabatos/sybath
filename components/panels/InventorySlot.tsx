import getIcon from "@/methods/functions/icons/getIcon"
import { useDraggable, useDroppable } from "@dnd-kit/react"
import styles from "./styles/PanelPlayerContainer.module.css"

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

export function InventorySlot({ inventory, placeholderIcon }: TProps) {
  const hasItem = inventory?.itemId

  const draggable = useDraggable({
    id: `item-${inventory?.slotId || Math.random()}`,
    disabled: !hasItem,
    data: inventory,
  })

  const droppable = useDroppable({
    id: `slot-${inventory?.slotId || Math.random()}`,
    data: inventory,
  })

  return (
    <div
      ref={droppable.ref}
      className={`${styles.slot} ${hasItem ? styles.occupied : ""} ${droppable.isDropTarget ? styles.dragOver : ""}`}
    >
      {hasItem ? (
        <div
          ref={draggable.ref}
          className={`${styles.item} ${draggable.isDragging ? styles.dragging : ""}`}
        >
          <span className={styles.itemImage}>{getIcon(inventory.image)}</span>
          <span className={styles.itemName}>{inventory.name}</span>
          <span>{inventory.slotId}</span>
          {inventory.quantity && inventory.quantity >= 1 ? (
            <span className={styles.quantity}> x{inventory.quantity}</span>
          ) : null}
        </div>
      ) : (
        (droppable.isDropTarget && <div className={styles.dropHint}>↓</div>) || (
          <div>
            {getIcon(placeholderIcon)}
            <span>{inventory?.slotId}</span>
          </div>
        )
      )}
    </div>
  )
}
