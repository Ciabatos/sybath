"use client"

import { PanelPlayerContainer } from "@/components/panels/PanelPlayerContainer"
import { PanelPlayerGear } from "@/components/panels/PanelPlayerGear"
import { usePlayerInventory } from "@/methods/hooks/inventory/composite/usePlayerInventory"
import { DragDropProvider } from "@dnd-kit/react"
import styles from "./styles/PanelPlayerInventory.module.css"

export function PanelPlayerInventory() {
  const { moveOrSwapItem } = usePlayerInventory()

  function handleDragEnd(event: any) {
    const { operation } = event
    const source = operation?.source
    const target = operation?.target

    if (!target) return
    const sourceData = source.data
    const targetData = target.data
    console.log(sourceData, targetData)

    if (!sourceData?.itemId) return

    const sourceId = sourceData.id
    const sourceName = sourceData.name
    const sourceDescription = sourceData.description
    const sourceImage = sourceData.image
    const sourceSlotId = sourceData.slotId
    const sourceContainerId = sourceData.containerId
    const sourceItemId = sourceData.itemId
    const sourceQuantity = sourceData.quantity

    const targetId = targetData.id
    const targetName = targetData.name
    const targetDescription = targetData.description
    const targetImage = targetData.image
    const targetSlotId = targetData.slotId
    const targetContainerId = targetData.containerId
    const targetItemId = targetData.itemId
    const targetQuantity = targetData.quantity

    moveOrSwapItem({
      fromSlotId: sourceSlotId,
      toSlotId: targetSlotId,
      fromInventoryContainerId: sourceContainerId,
      toInventoryContainerId: targetContainerId,
      fromItemId: sourceItemId,
      toItemId: targetItemId,
      fromName: sourceName,
      toName: targetName,
      fromQuantity: sourceQuantity,
      toQuantity: targetQuantity,
    })
  }

  return (
    <DragDropProvider onDragEnd={handleDragEnd}>
      <div className={styles.wrapper}>
        <PanelPlayerGear />
        <PanelPlayerContainer />
      </div>
    </DragDropProvider>
  )
}
