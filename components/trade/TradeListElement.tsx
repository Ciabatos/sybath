"use client"
import styles from "./styles/Recipe.module.css"

interface TTradeProps {
  icon: React.ReactNode
  status: number
  createdAt: string
  updatedAt: string
  expiresAt: string
}

export default function TradeElementList({ icon, status, createdAt, updatedAt, expiresAt }: TTradeProps) {
-- uzyc plop nestes list !!!!
  return (
    <div className={styles.listItem}>
      <div className={styles.listItemIcon}>
        <span className={styles.listItemIconEmoji}>{icon}</span>
      </div>
      <div className={styles.listItemContent}>
        <div className={styles.listItemHeader}>
          <h3 className={styles.listItemName}>{name}</h3>
          <div className={styles.listItemStat}>
            <span>
              {value}
              {hasMax && <span>/{maxValue}</span>}
            </span>
            {hasMax && (
              <div className={styles.listItemBar}>
                <div
                  className={styles.listItemBarFill}
                  style={{ width: `${percentage}%` }}
                />
              </div>
            )}
          </div>
        </div>
        <p className={styles.listItemDescription}>{description}</p>
      </div>
    </div>
  )
}
