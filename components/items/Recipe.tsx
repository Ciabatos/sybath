"use client"
import styles from "./styles/Recipe.module.css"

interface TRecipeProps {
  icon: React.ReactNode
  name: string
  value: number
  maxValue: number
  description: string
  canCraft: boolean
}

export default function Recipe({ icon, name, value, maxValue, description, canCraft }: TRecipeProps) {
  const hasMax = maxValue !== undefined && value !== undefined
  const percentage = hasMax ? (value / maxValue) * 100 : 0

  return (
    <div className={`${styles.listItem} ${value > 0 && canCraft ? "" : styles.listItemDisabled}`}>
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
