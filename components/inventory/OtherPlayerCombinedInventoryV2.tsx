"use client"

import { OtherPlayerContainer } from "@/components/inventory/OtherPlayerContainer"
import { OtherPlayerGearV2 } from "@/components/inventory/OtherPlayerGearV2"
import styles from "./styles/PlayerCombinedInventory.module.css"

export function OtherPlayerCombinedInventory() {
  return (
    <div className={styles.wrapper}>
      <OtherPlayerGearV2 />
      <OtherPlayerContainer />
    </div>
  )
}