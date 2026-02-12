"use client"
import styles from "./styles/Skill.module.css"

interface TSkillProps {
  icon: React.ReactNode
  name: string
  value: number
  maxValue?: number
  description?: string
}

export default function Skill({ icon, name, value, maxValue, description }: TSkillProps) {
  const hasMax = maxValue !== undefined
  const percentage = hasMax ? (value / maxValue) * 100 : 0

  return (
    <div className={styles.skillItem}>
      <div className={styles.skillIcon}>
        <span className={styles.iconEmoji}>{icon}</span>
      </div>
      <div className={styles.skillContent}>
        <div className={styles.skillHeader}>
          <h3 className={styles.skillName}>{name}</h3>
          <div className={styles.skillLevel}>
            <span className={styles.levelText}>
              {value}
              {hasMax && <span className={styles.statMax}>/{maxValue}</span>}
            </span>
            <div className={styles.levelBar}>
              <div
                className={styles.levelProgress}
                style={{ width: `${percentage}%` }}
              />
            </div>
          </div>
        </div>
        <p className={styles.skillDescription}>{description}</p>
      </div>
    </div>
  )
}
