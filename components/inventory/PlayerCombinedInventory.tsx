"use client"

import { PlayerContainer } from "@/components/inventory/PlayerContainer"
import { PanelPlayerGear } from "@/components/panels/PanelPlayerGear"
import styles from "./styles/PlayerCombinedInventory.module.css"

export function PlayerCombinedInventory() {
  return (
    <div className={styles.wrapper}>
      <PanelPlayerGear />
      <PlayerContainer />
    </div>
  )
}
