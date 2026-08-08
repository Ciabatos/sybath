// GENERATED CODE - DO EDIT MANUALLY - createListPanels.hbs
"use client"
import { Button } from "@/components/ui/button"
import { useTrades } from "@/methods/hooks/trade/composite/useTrades"
import styles from "./styles/TradesElement.module.css"

interface TTradesElementProps {
  icon: React.ReactNode
  id: number
  status: number
  createdAt: string
  updatedAt: string
  expiresAt: string
}

export default function TradesElement({ icon, id, status, createdAt, updatedAt, expiresAt }: TTradesElementProps) {
  const { handleClickOnTrade } = useTrades()

  return (
    <Button
      onClick={() => handleClickOnTrade(id)}
      className={styles.listItem}
    >
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
    </Button>
  )
}
