"use client"

import { InventoryInspector } from "@/components/inventory/InventoryInspector"
import { TInventorySlot } from "@/components/inventory/InventorySlot"
import { PlayerContainer } from "@/components/inventory/PlayerContainer"
import { PlayerGear } from "@/components/inventory/PlayerGear"
import OpenTrades from "@/components/trade/OpenTrades"
import { TooltipProvider } from "@/components/ui/tooltip"
import { useState } from "react"
import styles from "./styles/PlayerCombinedInventory.module.css"

export function PlayerCombinedInventory() {
  // Jeden stan zaznaczenia dla gearu i plecaka + jeden inspector na dole.
  // Dwa osobne paski szczegółów zabierały ok. 120px pionowego miejsca.
  const [selected, setSelected] = useState<TInventorySlot | null>(null)

  return (
    <TooltipProvider delayDuration={200}>
      <div className={styles.wrapper}>
        <div className={styles.actions}>
          <OpenTrades />
        </div>

        <PlayerGear
          selected={selected}
          onSelect={setSelected}
        />
        <PlayerContainer
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