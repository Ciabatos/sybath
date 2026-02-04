"use client"

import { PanelPlayerContainer } from "@/components/panels/PanelPlayerContainer"
import { PanelPlayerGear } from "@/components/panels/PanelPlayerGear"
import { useInventory } from "@/methods/hooks/inventory/composite/useInventory"
import styles from "./styles/PanelPlayerInventory.module.css"

export function PanelPlayerInventory() {
  const inventory = useInventory()
  return (
    <div className={styles.wrapper}>
      <PanelPlayerGear />
      <PanelPlayerContainer />
    </div>
  )
}
