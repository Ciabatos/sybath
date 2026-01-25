"use client"

import { PanelPlayerContainer } from "@/components/panels/PanelPlayerContainer"
import { PanelPlayerGear } from "@/components/panels/PanelPlayerGear"
import styles from "./styles/PanelPlayerInventory.module.css"

export function PanelPlayerInventory() {
  return (
    <div className={styles.wrapper}>
      <PanelPlayerGear />
      <PanelPlayerContainer />
    </div>
  )
}
