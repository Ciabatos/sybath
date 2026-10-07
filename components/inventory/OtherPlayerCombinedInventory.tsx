"use client"

import { OtherPlayerContainer } from "@/components/inventory/OtherPlayerContainer"
import { OtherPlayerGear } from "@/components/inventory/OtherPlayerGear"
import { TooltipProvider } from "@/components/ui/tooltip"
import styles from "./styles/PlayerCombinedInventory.module.css"

export function OtherPlayerCombinedInventory() {
  return (
    <TooltipProvider delayDuration={200}>
      <div className={styles.wrapper}>
        <OtherPlayerGear />
        <OtherPlayerContainer />
      </div>
    </TooltipProvider>
  )
}