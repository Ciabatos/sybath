import getIcon from "@/methods/functions/icons/getIcon"
import { usePlayerStats } from "@/methods/hooks/attributes/composite/usePlayerStats"
import type React from "react"
import styles from "./styles/PanelPlayerStats.module.css"

type TStatProps = {
  icon: React.ReactNode
  name: string
  value: number
  maxValue?: number
  description?: string
}

function Stat({ icon, name, value, maxValue, description }: TStatProps) {
  const hasMax = maxValue !== undefined
  const percentage = hasMax ? (value / maxValue) * 100 : 0

  return (
    <div className={styles.statItem}>
      <div className={styles.statIcon}>{icon}</div>
      <div className={styles.statInfo}>
        <div className={styles.statHeader}>
          <span className={styles.statLabel}>{name}</span>
          <span className={styles.statValue}>
            {value}
            {hasMax && <span className={styles.statMax}>/{maxValue}</span>}
          </span>
        </div>
        {hasMax && (
          <div className={styles.statBarContainer}>
            <div
              className={styles.statBar}
              style={{ width: `${percentage}%` }}
            />
          </div>
        )}
        {description && <p className={styles.statDescription}>{description}</p>}
      </div>
    </div>
  )
}

export function PanelPlayerStats() {
  const { combinedPlayerStats } = usePlayerStats()

  return (
    <div className={styles.container}>
      <div className={styles.section}>
        <h3 className={styles.sectionTitle}>Stats</h3>
        <div className={styles.statsGrid}>
          {combinedPlayerStats.map((playerStat) => (
            <Stat
              key={playerStat.id}
              icon={getIcon(playerStat.image)}
              name={playerStat.name}
              value={playerStat.value}
              maxValue={10}
              description={playerStat.description}
            />
          ))}
        </div>
      </div>
    </div>
  )
}
