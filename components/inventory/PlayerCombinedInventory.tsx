"use client"

import { PlayerContainer } from "@/components/inventory/PlayerContainer"
import { PlayerGear } from "@/components/inventory/PlayerGear"
import OpenTrades from "@/components/trade/OpenTrades"
import { TooltipProvider } from "@/components/ui/tooltip"
import styles from "./styles/PlayerCombinedInventory.module.css"

export function PlayerCombinedInventory() {
  return (
    <TooltipProvider delayDuration={200}>
      <div className={styles.wrapper}>
        <div className={styles.actions}>
          <OpenTrades />
        </div>
        <PlayerGear />
        <PlayerContainer />
      </div>
    </TooltipProvider>
  )
}

