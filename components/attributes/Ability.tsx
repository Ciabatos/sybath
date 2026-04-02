"use client"
import styles from "./styles/Ability.module.css"

interface TAbilityProps {
  icon: React.ReactNode
  name: string
  description?: string
}

export default function Ability({ icon, name, description }: TAbilityProps) {
  return (
    <div className={styles.abilityItem}>
      <div className={styles.abilityIcon}>
        <span className={styles.iconEmoji}>{icon}</span>
        <div className={styles.cooldownBadge}>{`X`}</div>
      </div>
      <div className={styles.abilityContent}>
        <div className={styles.abilityHeader}>
          <h3 className={styles.abilityName}>{name}</h3>
        </div>
      </div>
      <p className={styles.abilityDescription}>{description}</p>
    </div>
  )
}
