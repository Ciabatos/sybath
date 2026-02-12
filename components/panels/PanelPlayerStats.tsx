import PlayerStats from "@/components/attributes/PlayerStats"
import styles from "./styles/PanelPlayerStats.module.css"

export function PanelPlayerStats() {
  return (
    <div className={styles.container}>
      <PlayerStats />
    </div>
  )
}
