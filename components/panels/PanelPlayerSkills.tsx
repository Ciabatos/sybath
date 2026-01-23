"use client"
import getIcon from "@/methods/functions/icons/getIcon"
import { usePlayerSkills } from "@/methods/hooks/attributes/composite/usePlayerSkills"
import styles from "./styles/PanelPlayerSkills.module.css"

interface TSkillProps {
  icon: React.ReactNode
  name: string
  value: number
  maxValue?: number
  description?: string
}

function Skill({ icon, name, value, maxValue, description }: TSkillProps) {
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

export function PanelPlayerSkills() {
  const { skills, playerSkills } = usePlayerSkills()

  const combinedPlayerSkills = Object.entries(playerSkills).map(([key, playerSkill]) => ({
    ...playerSkill,
    ...skills[playerSkill.skillId],
  }))

  return (
    <div className={styles.skillsContainer}>
      <p>
        Skills slużą do pokazania jakie umiejętności posiada postać. Można je przekazywać innym postaciom ale nie są to
        aktywne abilities
      </p>
      <div className={styles.skillsGrid}>
        {combinedPlayerSkills.map((playerSkill) => (
          <Skill
            key={playerSkill.id}
            icon={getIcon(playerSkill.image)}
            name={playerSkill.name}
            value={playerSkill.value}
            maxValue={10}
            description={playerSkill.description}
          />
        ))}
      </div>
    </div>
  )
}
