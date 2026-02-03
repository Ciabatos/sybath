import getIcon from "@/methods/functions/icons/getIcon"
import { useDraggable, useDroppable } from "@dnd-kit/react"
import styles from "./styles/PanelPlayerContainer.module.css"

type TInventorySlot = {
  id: number
  name: string
  description?: string | undefined
  image: string
  slotId: number
  containerId: number
  itemId: number
  quantity: number
}

type TProps = {
  inventory: TInventorySlot
}

export function InventorySlot({ inventory }: TProps) {
  const draggable = useDraggable({
    id: `item-${inventory.slotId}`,
    disabled: !inventory.itemId,
    data: inventory,
  })

  const droppable = useDroppable({
    id: `slot-${inventory.slotId}`,
    data: inventory,
  })

  const handleDoubleClick = () => {
    if (!inventory.itemId) return
    console.log(`Context menu for item: ${inventory.name} in slot ${inventory.slotId}`)
  }

  return (
    <div
      ref={droppable.ref}
      className={`${styles.slot} ${inventory.itemId ? styles.occupied : ""} ${droppable.isDropTarget ? styles.dragOver : ""}`}
    >
      {inventory.itemId ? (
        <div
          ref={draggable.ref}
          className={`${styles.item} ${draggable.isDragging ? styles.dragging : ""}`}
          onDoubleClick={handleDoubleClick}
        >
          <span className={styles.itemImage}>{getIcon(inventory.image)}</span>
          <span className={styles.itemName}>{inventory.name}</span>
          {inventory.quantity && inventory.quantity >= 1 ? (
            <span className={styles.quantity}> x{inventory.quantity}</span>
          ) : null}
        </div>
      ) : (
        droppable.isDropTarget && <div className={styles.dropHint}>↓</div>
      )}
    </div>
  )
}
