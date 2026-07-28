"use client"

import { PlayerContainer } from "@/components/inventory/PlayerContainer"
import { PlayerGear } from "@/components/inventory/PlayerGear"
import styles from "./styles/PlayerCombinedInventory.module.css"

export function PlayerCombinedInventory() {
  return (
    <div className={styles.wrapper}>
      <div>Trade requests</div>
      <PlayerGear />
      <PlayerContainer />
    </div>
  )
}
