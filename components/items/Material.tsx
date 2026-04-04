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
    <div className={`${styles.skillItem} ${missingQuantity > 0 ? styles.disabled : ""}`}>
      <div className={styles.skillIcon}>
        <span className={styles.iconEmoji}>{icon}</span>
      </div>
      <div className={styles.skillContent}>
        <div className={styles.skillHeader}>
          <h3 className={styles.skillName}>
            {name} x {quantity}
          </h3>
        </div>
        <p className={styles.skillDescription}>{description}</p>
        <div className={styles.skillName}>
          <p>Owned: {ownedQuantity}</p>
          <p>Missing: {missingQuantity}</p>
          {missingQuantity > 0 && canCraftMissing && <p>Can craft missing</p>}
        </div>
      </div>
    </div>
  )
}
