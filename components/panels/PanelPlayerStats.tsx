import { usePlayerStats } from "@/methods/hooks/attributes/composite/usePlayerStats"
import getIcon from "@/types/icons/getIcon"
import type React from "react"
import styles from "./styles/PanelPlayerStats.module.css"

type StatItemProps = {
  icon: React.ReactNode
  label: string
  value: number
  maxValue?: number
  description?: string
}

function StatItem({ icon, label, value, maxValue, description }: StatItemProps) {
  const hasMax = maxValue !== undefined
  const percentage = hasMax ? (value / maxValue) * 100 : 0

  return (
    <div className={styles.statItem}>
      <div className={styles.statIcon}>{icon}</div>
      <div className={styles.statInfo}>
        <div className={styles.statHeader}>
          <span className={styles.statLabel}>{label}</span>
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
  const { stats, playerStats } = usePlayerStats()

  const combinedPlayerStats = Object.entries(playerStats).map(([key, playerStat]) => ({
    ...playerStat,
    ...stats[playerStat.statId],
  }))

  return (
    <div className={styles.container}>
      <div className={styles.section}>
        <h3 className={styles.sectionTitle}>Stats</h3>
        <div className={styles.statsGrid}>
          {combinedPlayerStats.map((playerStats) => (
            <StatItem
              key={playerStats.id}
              icon={getIcon(playerStats.image)}
              label={playerStats.name}
              value={playerStats.value}
              maxValue={10}
              description={playerStats.description}
            />
          ))}
        </div>
      </div>
    </div>
  )
}
