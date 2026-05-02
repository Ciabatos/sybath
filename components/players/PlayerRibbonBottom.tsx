// GENERATED CODE - DO EDIT MANUALLY - createPanels.hbs
"use client"
import PlayerEnergyBar from "@/components/players/PlayerEnergyBar"
import { useModalBottomRight } from "@/methods/hooks/modals/useModalBottomRight"
import styles from "./styles/PlayerRibbonBottom.module.css"

export default function PlayerRibbonBottom() {
  const { resetModalBottomRight } = useModalBottomRight()

  function closePlayerRibbonBottom() {
    resetModalBottomRight()
  }

  return (
    <div className={styles.overlay}>
      <div className={styles.panel}>
        <PlayerEnergyBar />
      </div>
    </div>
  )
}
