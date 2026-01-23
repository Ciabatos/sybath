"use client"
import getIcon from "@/methods/functions/icons/getIcon"
import { usePlayerAbilities } from "@/methods/hooks/attributes/composite/usePlayerAbilities"
import styles from "./styles/PanelPlayerAbilities.module.css"
interface TAbilityProps {
  icon: React.ReactNode
  name: string
  value: number
  maxValue?: number
  description?: string
}

function Ability({ icon, name, value, maxValue, description }: TAbilityProps) {
  const hasMax = maxValue !== undefined
  const percentage = hasMax ? (value / maxValue) * 100 : 0

  return (
    <div className={styles.abilityItem}>
      <div className={styles.abilityIcon}>
        <span className={styles.iconEmoji}>{icon}</span>
        <div className={styles.cooldownBadge}>{`X`}</div>
      </div>
      <div className={styles.abilityContent}>
        <div className={styles.abilityHeader}>
          <h3 className={styles.abilityName}>{name}</h3>
          <div className={styles.abilityLevel}>
            <span className={styles.levelText}>
              {value}/{maxValue}
            </span>
            <div className={styles.levelBar}>
              <div
                className={styles.levelProgress}
                style={{ width: `${percentage}%` }}
              />
            </div>
          </div>
        </div>
        <p className={styles.abilityDescription}>{description}</p>
      </div>
    </div>
  )
}

export function PanelPlayerAbilities() {
  const { combinedPlayerAbilities } = usePlayerAbilities()

  return (
    <div className={styles.abilitiesContainer}>
      <p>
        Abilities służą do używania, są to aktywne umiejętności, które można używać w walce lub produkcji i innych
        sytuacjach, ability powstaja jeżeli masz różne kombinacje skills, stats i knowledge.
      </p>
      <div className={styles.abilitiesGrid}>
        {combinedPlayerAbilities.map((playerAbility) => (
          <Ability
            key={playerAbility.id}
            icon={getIcon(playerAbility.image)}
            name={playerAbility.name}
            value={playerAbility.value}
            maxValue={10}
            description={playerAbility.description}
          />
        ))}
      </div>
    </div>
  )
}
