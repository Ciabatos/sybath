"use client"

import SquadSwitchList from "@/components/squad/SquadSwitchList"
import { ArrowLeftRight } from "lucide-react"
import { useState } from "react"
import styles from "./styles/SquadSwitchButton.module.css"

export default function SquadSwitchButton() {
  const [open, setOpen] = useState(false)

  const handleClick = () => {
    setOpen(!open)
  }

  return (
    <>
      <button
        className={styles.switchButton}
        onClick={() => handleClick()}
      >
        <ArrowLeftRight className={styles.icon} />
      </button>
      {open && <SquadSwitchList />}
    </>
  )
}
