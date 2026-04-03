"use client"
import styles from "./styles/Material.module.css"

interface TMaterialProps {
  icon: React.ReactNode
  itemId: number
  quantity: number
  name: string
  description: string
}

export default function Material({ icon, itemId, quantity, name, description }: TMaterialProps) {
  return (
    <div className={styles.skillItem}>
      <div className={styles.skillIcon}>
        <span className={styles.iconEmoji}>{icon}</span>
      </div>
      <div className={styles.skillContent}>
        <div className={styles.skillHeader}>
          <h3 className={styles.skillName}>{name}</h3>
        </div>
        <p className={styles.skillDescription}>{description}</p>
      </div>
    </div>
  )
}
