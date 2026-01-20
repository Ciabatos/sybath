"use client"

import PanelPlayerSwitchList from "@/components/panels/PanelPlayerSwitchList"
import styles from "@/components/panels/styles/PlayerSwitchButton.module.css"
import { ArrowLeftRight } from "lucide-react"

export default function PlayerSwitchButton() {
  const handleClick = () => {
    // openModalLeftTopBar(EPanelsLeftTopBar.PanelPlayerPanel)
    //zadnych modali, uzyc tooltipa
  }

  return (
    <div>
      <button
        className={styles.switchButton}
        aria-label='Switch hero'
        onClick={() => handleClick()}
      >
        <ArrowLeftRight className={styles.icon} />
      </button>
      <PanelPlayerSwitchList></PanelPlayerSwitchList>
    </div>
  )
}
