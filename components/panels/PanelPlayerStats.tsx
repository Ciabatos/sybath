import { Activity, Award, Heart, Shield, Swords, Target, TrendingUp, Zap } from "lucide-react"
import type React from "react"
import styles from "./styles/PanelPlayerStats.module.css"

type StatItemProps = {
  icon: React.ReactNode
  label: string
  value: number
  maxValue?: number
  description?: string
}

function StatItem({ icon, label, value, maxValue, description }: StatItemProps) {
  const hasMax = maxValue !== undefined
  const percentage = hasMax ? (value / maxValue) * 100 : 0

  return (
    <div className={styles.statItem}>
      <div className={styles.statIcon}>{icon}</div>
      <div className={styles.statInfo}>
        <div className={styles.statHeader}>
          <span className={styles.statLabel}>{label}</span>
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

export function PanelPlayerStats() {
  return (
    <div className={styles.container}>
      <div className={styles.section}>
        <h3 className={styles.sectionTitle}>Core Stats</h3>
        <div className={styles.statsGrid}>
          <StatItem
            icon={<Heart className={styles.iconRed} />}
            label='Health'
            value={140}
            maxValue={140}
            description="Your character's life force"
          />
          <StatItem
            icon={<Zap className={styles.iconYellow} />}
            label='Stamina'
            value={110}
            maxValue={110}
            description='Energy for physical actions'
          />
          <StatItem
            icon={<Shield className={styles.iconBlue} />}
            label='Resolve'
            value={70}
            maxValue={70}
            description='Mental fortitude and morale'
          />
          <StatItem
            icon={<TrendingUp className={styles.iconGreen} />}
            label='Initiative'
            value={81}
            description='Turn order in combat'
          />
        </div>
      </div>

      <div className={styles.section}>
        <h3 className={styles.sectionTitle}>Combat Stats</h3>
        <div className={styles.statsGrid}>
          <StatItem
            icon={<Swords className={styles.iconOrange} />}
            label='Melee Attack'
            value={65}
            description='Chance to hit with melee weapons'
          />
          <StatItem
            icon={<Target className={styles.iconPurple} />}
            label='Ranged Attack'
            value={52}
            description='Chance to hit with ranged weapons'
          />
          <StatItem
            icon={<Activity className={styles.iconCyan} />}
            label='Melee Defense'
            value={44}
            description='Chance to avoid melee attacks'
          />
          <StatItem
            icon={<Award className={styles.iconGold} />}
            label='Ranged Defense'
            value={33}
            description='Chance to avoid ranged attacks'
          />
        </div>
      </div>
    </div>
  )
}
