"use client"
import styles from "./styles/Stat.module.css"

type TStatProps = {
  icon: React.ReactNode
  name: string
  value: number
  maxValue?: number
  description?: string
}

export default function Stat({ icon, name, value, maxValue, description }: TStatProps) {
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
