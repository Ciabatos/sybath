"use client"
import styles from "./styles/TradeListElement.module.css"

interface TTradeProps {
  icon: React.ReactNode
  id: number
  status: number
  createdAt: string
  updatedAt: string
  expiresAt: string
}

export default function TradeElementList({ icon, id, status, createdAt, updatedAt, expiresAt }: TTradeProps) {
  // -- uzyc plop nestes list !!!!
  return (
    <div className={styles.listItem}>
      <div className={styles.listItemIcon}>
        <span className={styles.listItemIconEmoji}>{icon}</span>
      </div>
      <div className={styles.listItemContent}>
        <div className={styles.listItemHeader}>
          <h3 className={styles.listItemName}>{id}</h3>
          <div className={styles.listItemStat}>
            <span>{status}</span>
            {createdAt}
            {updatedAt}
            {expiresAt}
          </div>
        </div>
        <p className={styles.listItemDescription}>{status}</p>
      </div>
    </div>
  )
}
