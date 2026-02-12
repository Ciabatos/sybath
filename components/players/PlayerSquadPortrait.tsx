"use client"
import { Users } from "lucide-react"
import styles from "./styles/PlayerSquadPortrait.module.css"

export default function PlayerSquadPortrait() {
  return (
    <div className={styles.iconWrapper}>
      <Users className={styles.squadIcon} />
      <span className={styles.squadLabel}>Squad</span>
    </div>
  )
}
