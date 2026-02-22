"use client"

import { OtherPlayerContainer } from "@/components/inventory/OtherPlayerContainer"
import { OtherPlayerGear } from "@/components/inventory/OtherPlayerGear"
import styles from "./styles/PlayerCombinedInventory.module.css"

export function OtherPlayerCombinedInventory() {
  return (
    <div className={styles.wrapper}>
      <OtherPlayerGear />
      <OtherPlayerContainer />
    </div>
  )
}
