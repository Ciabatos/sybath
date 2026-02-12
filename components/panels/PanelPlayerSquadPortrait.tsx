"use client"
import { Users } from "lucide-react"
import styles from "./styles/PanelPlayerSquadPortrait.module.css"

export default function PanelPlayerSquadPortrait() {
  return (
    <div className={styles.iconWrapper}>
      <Users className={styles.squadIcon} />
      <span className={styles.squadLabel}>Squad</span>
    </div>
  )
}
