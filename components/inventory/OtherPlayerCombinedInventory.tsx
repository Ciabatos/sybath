"use client"

import { InventoryInspector } from "@/components/inventory/InventoryInspector"
import { TInventorySlot } from "@/components/inventory/InventorySlot"
import { OtherPlayerContainer } from "@/components/inventory/OtherPlayerContainer"
import { OtherPlayerGear } from "@/components/inventory/OtherPlayerGear"
import { TooltipProvider } from "@/components/ui/tooltip"
import { useState } from "react"
import styles from "./styles/PlayerCombinedInventory.module.css"

export function OtherPlayerCombinedInventory() {
  const [selected, setSelected] = useState<TInventorySlot | null>(null)

  return (
    <TooltipProvider delayDuration={200}>
      <div className={styles.wrapper}>
        <OtherPlayerGear
          selected={selected}
          onSelect={setSelected}
        />
        <OtherPlayerContainer
          selected={selected}
          onSelect={setSelected}
        />

        <InventoryInspector
          slot={selected}
          emptyHint='Select an item to read its description'
        />
      </div>
    </TooltipProvider>
  )
}