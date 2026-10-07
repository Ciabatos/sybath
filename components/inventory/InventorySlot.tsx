import { InventorySlotTooltip } from "@/components/inventory/InventorySlotTooltip"
import getIcon from "@/methods/functions/icons/getIcon"
import { useDraggable, useDroppable } from "@dnd-kit/react"
import { ReactNode, useCallback, useEffect, useState } from "react"
import styles from "./styles/InventorySlot.module.css"

export type TInventorySlot = {
  type: `playerGearInventory` | `playerInventory` | `otherPlayerGearInventory` | `otherPlayerInventory`
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
  /** Podpis slotu gearowego, np. "Helmet". Używany w podpisie pod miniaturą i w tooltipie. */
  slotLabel?: string
  /** Zaznaczenie slotu (kliknięcie) — steruje paskiem szczegółów na mobile. */
  selected?: boolean
  onSelect?: (slot: TInventorySlot) => void
}

type TSlotView = {
  hasItem: boolean
  icon: ReactNode
  title: string
  description?: string
  quantity: number
  slotLabel?: string
}

function DraggableItem({
  id,
  inventory,
  onDraggingChange,
}: {
  id: string
  inventory: TInventorySlot
  onDraggingChange: (dragging: boolean) => void
}) {
  const { ref, isDragging } = useDraggable({
    id,
    type: "item",
    data: inventory,
  })

  // Tooltip musi zniknąć w trakcie przeciągania — inaczej podąża za kursorem
  // albo palcem i zasłania siatkę slotów.
  useEffect(() => {
    onDraggingChange(isDragging)
  }, [isDragging, onDraggingChange])

  return (
    <div
      ref={ref}
      className={`${styles.item} ${isDragging ? styles.dragging : ""}`}
    >
      <span className={styles.itemImage}>{getIcon(inventory.image)}</span>
      {inventory.quantity > 1 && <span className={styles.quantity}>{inventory.quantity}</span>}
    </div>
  )
}

function SlotFrame({
  view,
  dropRef,
  isDropTarget,
  selected,
  onClick,
  children,
}: {
  view: TSlotView
  dropRef?: (node: HTMLDivElement | null) => void
  isDropTarget?: boolean
  selected?: boolean
  onClick?: () => void
  children: ReactNode
}) {
  return (
    <div className={styles.slotCell}>
      <div
        ref={dropRef}
        onClick={onClick}
        className={`${styles.slot} ${view.hasItem ? styles.slotFilled : styles.slotEmpty} ${
          selected ? styles.selected : ""
        } ${isDropTarget ? styles.dragOver : ""}`}
      >
        {children}
        {isDropTarget && !view.hasItem && (
          <div
            className={styles.dropHint}
            aria-hidden
          >
            +
          </div>
        )}
      </div>
      {view.slotLabel && <span className={styles.slotCaption}>{view.slotLabel}</span>}
    </div>
  )
}

// Główny komponent InventorySlot używający oddzielnych komponentów
export function InventorySlot({ inventory, placeholderIcon, slotLabel, selected, onSelect }: TProps) {
  const [isDragging, setIsDragging] = useState(false)
  const handleDraggingChange = useCallback((dragging: boolean) => setIsDragging(dragging), [])

  const hasItem = Boolean(inventory?.itemId)

  const view: TSlotView = {
    hasItem,
    icon: hasItem && inventory ? getIcon(inventory.image) : placeholderIcon ? getIcon(placeholderIcon) : null,
    title: hasItem && inventory ? inventory.name : (slotLabel ?? "Empty slot"),
    description: hasItem ? inventory?.description : undefined,
    quantity: inventory?.quantity ?? 0,
    slotLabel,
  }

  const body =
    hasItem && inventory ? (
      <DraggableItem
        id={`item-${inventory.containerId}-${inventory.slotId}`}
        inventory={inventory}
        onDraggingChange={handleDraggingChange}
      />
    ) : (
      <div className={styles.placeholder}>
        {placeholderIcon && <span className={styles.placeholderIcon}>{getIcon(placeholderIcon)}</span>}
      </div>
    )

  // Slot bez rekordu w bazie nie może przyjąć upuszczonego przedmiotu — brakuje danych
  // wymaganych przez `useInventoryMonitor` (m.in. containerId i slotTypeId).
  // Renderujemy go statycznie, bez useDroppable.
  if (!inventory) {
    return (
      <InventorySlotTooltip
        title={view.title}
        icon={view.icon}
        empty
      >
        <SlotFrame view={view}>{body}</SlotFrame>
      </InventorySlotTooltip>
    )
  }

  const slotId = `slot-${inventory.containerId}-${inventory.slotId}`

  return (
    <DroppableSlot
      id={slotId}
      data={inventory}
      view={view}
      tooltipOpen={isDragging ? false : undefined}
      selected={selected}
      onSelect={onSelect}
      onDraggingChange={handleDraggingChange}
    >
      {body}
    </DroppableSlot>
  )
}

function DroppableSlot({
  id,
  data,
  view,
  tooltipOpen,
  selected,
  onSelect,
  onDraggingChange,
  children,
}: {
  id: string
  data: TInventorySlot
  view: TSlotView
  tooltipOpen?: boolean
  selected?: boolean
  onSelect?: (slot: TInventorySlot) => void
  onDraggingChange: (dragging: boolean) => void
  children: ReactNode
}) {
  const { ref, isDropTarget } = useDroppable({
    id,
    accept: "item",
    data,
  })

  const handleClick = useCallback(() => {
    onSelect?.(data)
  }, [onSelect, data])

  return (
    <InventorySlotTooltip
      title={view.title}
      description={view.description}
      icon={view.icon}
      empty={!view.hasItem}
      open={tooltipOpen}
      meta={[
        { label: "Quantity", value: view.hasItem ? String(view.quantity) : "—" },
        { label: "Slot", value: view.slotLabel ?? `#${data.slotId}` },
      ]}
    >
      <SlotFrame
        view={view}
        dropRef={ref}
        isDropTarget={isDropTarget}
        selected={selected}
        onClick={handleClick}
      >
        {children}
      </SlotFrame>
    </InventorySlotTooltip>
  )
}
