"use client"
import styles from "./styles/Material.module.css"

interface TMaterialProps {
  icon: React.ReactNode
  itemId: number
  quantity: number
  name: string
  description: string
  ownedQuantity: number
  missingQuantity: number
  canCraftMissing: boolean
}

export default function Material({
  icon,
  itemId,
  quantity,
  name,
  description,
  ownedQuantity,
  missingQuantity,
  canCraftMissing,
}: TMaterialProps) {
  return (
    <div className={`${styles.listItem} ${missingQuantity > 0 ? styles.listItemDisabled : ""}`}>
      <div className={styles.listItemIcon}>
        <span className={styles.listItemIconEmoji}>{icon}</span>
      </div>
      <div className={styles.listItemContent}>
        <div className={styles.listItemHeader}>
          <h3 className={styles.listItemName}>
            {name} x {quantity}
          </h3>
        </div>
        <p className={styles.listItemDescription}>{description}</p>
        <div className={styles.listItemStat}>
          <p>Owned: {ownedQuantity}</p>
          <p>Missing: {missingQuantity}</p>
          {missingQuantity > 0 && canCraftMissing && <p>Can craft missing</p>}
        </div>
      </div>
    </div>
  )
}
