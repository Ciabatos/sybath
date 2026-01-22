"use client"
import styles from "./styles/PanelPlayerAbilities.module.css"

interface Ability {
  id: string
  name: string
  description: string
  level: number
  maxLevel: number
  icon: string
  cooldown?: number
}

interface PanelPlayerAbilitiesProps {
  abilities?: Ability[]
}

const defaultAbilities: Ability[] = [
  {
    id: "1",
    name: "Shield Bash",
    description: "Stun an enemy with a powerful shield strike",
    level: 3,
    maxLevel: 5,
    icon: "🛡️",
    cooldown: 3,
  },
  {
    id: "2",
    name: "Battle Fury",
    description: "Increase attack damage for a short duration",
    level: 2,
    maxLevel: 5,
    icon: "⚔️",
    cooldown: 5,
  },
  {
    id: "3",
    name: "Defensive Stance",
    description: "Reduce incoming damage by 50% but attack slower",
    level: 4,
    maxLevel: 5,
    icon: "🏰",
    cooldown: 4,
  },
  {
    id: "4",
    name: "War Cry",
    description: "Boost morale of nearby allies, increasing their stats",
    level: 1,
    maxLevel: 3,
    icon: "📢",
    cooldown: 6,
  },
  {
    id: "5",
    name: "Quick Strike",
    description: "Execute a rapid attack that cannot be dodged",
    level: 3,
    maxLevel: 5,
    icon: "⚡",
    cooldown: 2,
  },
  {
    id: "6",
    name: "Iron Will",
    description: "Resist fear and morale penalties for battle",
    level: 2,
    maxLevel: 3,
    icon: "💪",
    cooldown: 0,
  },
]

export function PanelPlayerAbilities({ abilities = defaultAbilities }: PanelPlayerAbilitiesProps) {
  return (
    <div className={styles.abilitiesContainer}>
      <p>
        Abilities służą do używania, są to aktywne umiejętności, które można używać w walce lub produkcji i innych
        sytuacjach, ability powstaja jeżeli masz różne kombinacje skills, stats i knowledge.
      </p>
      <div className={styles.abilitiesGrid}>
        {abilities.map((ability) => (
          <div
            key={ability.id}
            className={styles.abilityItem}
          >
            <div className={styles.abilityIcon}>
              <span className={styles.iconEmoji}>{ability.icon}</span>
              {ability.cooldown !== undefined && ability.cooldown > 0 && (
                <div className={styles.cooldownBadge}>{ability.cooldown}t</div>
              )}
            </div>
            <div className={styles.abilityContent}>
              <div className={styles.abilityHeader}>
                <h3 className={styles.abilityName}>{ability.name}</h3>
                <div className={styles.abilityLevel}>
                  <span className={styles.levelText}>
                    Lvl {ability.level}/{ability.maxLevel}
                  </span>
                  <div className={styles.levelBar}>
                    <div
                      className={styles.levelProgress}
                      style={{ width: `${(ability.level / ability.maxLevel) * 100}%` }}
                    />
                  </div>
                </div>
              </div>
              <p className={styles.abilityDescription}>{ability.description}</p>
            </div>
          </div>
        ))}
      </div>
    </div>
  )
}
