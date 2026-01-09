"use client"

import styles from "@/components/panels/styles/PlayerSwitchButton.module.css"
import { ArrowLeftRight } from "lucide-react"

export default function PlayerSwitchButton() {
  return (
    <button
      className={styles.switchButton}
      aria-label='Switch hero'
    >
      <ArrowLeftRight className={styles.icon} />
    </button>
  )
}
