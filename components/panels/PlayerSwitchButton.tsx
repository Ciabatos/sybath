"use client"

import PanelPlayerSwitchList from "@/components/panels/PanelPlayerSwitchList"
import { ArrowLeftRight } from "lucide-react"
import { useState } from "react"
import styles from "./styles/PlayerSwitchButton.module.css"

export default function PlayerSwitchButton() {
  const [open, setOpen] = useState(false)

  const handleClick = () => {
    setOpen(!open)
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
      {open && <PanelPlayerSwitchList />}
    </div>
  )
}
