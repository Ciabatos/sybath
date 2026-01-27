import getIcon from "@/methods/functions/icons/getIcon"
import { useDraggable, useDroppable } from "@dnd-kit/react"
import styles from "./styles/PanelPlayerContainer.module.css"

type TPlayerInventory = {
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
  playerInventory: TPlayerInventory
}

export function InventorySlot({ playerInventory }: TProps) {
  const draggable = useDraggable({
    id: `item-${playerInventory.slotId}`,
    disabled: !playerInventory.itemId,
    data: playerInventory,
  })

  const droppable = useDroppable({
    id: `slot-${playerInventory.slotId}`,
    data: playerInventory,
  })

  const handleDoubleClick = () => {
    if (!playerInventory.itemId) return
    console.log(`Context menu for item: ${playerInventory.name} in slot ${playerInventory.slotId}`)
  }

  return (
    <div
      ref={droppable.ref}
      className={`${styles.slot} ${playerInventory.itemId ? styles.occupied : ""} ${droppable.isDropTarget ? styles.dragOver : ""}`}
      title={
        playerInventory.itemId
          ? `${playerInventory.name}${playerInventory.description ? `\n${playerInventory.description}` : ""}`
          : "Empty slot"
      }
    >
      {playerInventory.itemId ? (
        <div
          ref={draggable.ref}
          className={`${styles.item} ${draggable.isDragging ? styles.dragging : ""}`}
          onDoubleClick={handleDoubleClick}
        >
          <span className={styles.itemImage}>{getIcon(playerInventory.image)}</span>
          <span className={styles.itemName}>{playerInventory.name}</span>
          {playerInventory.quantity && playerInventory.quantity >= 1 ? (
            <span className={styles.quantity}> x{playerInventory.quantity}</span>
          ) : null}
        </div>
      ) : (
        droppable.isDropTarget && <div className={styles.dropHint}>↓</div>
      )}
    </div>
  )
}
