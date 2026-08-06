"use client"

import { PlayerContainer } from "@/components/inventory/PlayerContainer"
import { PlayerGear } from "@/components/inventory/PlayerGear"
import { Button } from "@/components/ui/button"
import { useModalTopCenter } from "@/methods/hooks/modals/useModalTopCenter"
import { EPanelsTopCenter } from "@/types/enumeration/EPanelsTopCenter"
import styles from "./styles/PlayerCombinedInventory.module.css"

export function PlayerCombinedInventory() {
  const { openModalTopCenter } = useModalTopCenter()

  function openTrades() {
    openModalTopCenter(EPanelsTopCenter.TradeList)
  }

  return (
    <div className={styles.wrapper}>
      <Button onClick={openTrades}>Trade requests</Button>
      <PlayerGear />
      <PlayerContainer />
    </div>
  )
}
