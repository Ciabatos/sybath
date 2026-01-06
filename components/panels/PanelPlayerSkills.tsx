"use client"
import styles from "./styles/PanelPlayerSkills.module.css"

interface Skill {
  id: string
  name: string
  description: string
  level: number
  maxLevel: number
  icon: string
  category: "Combat" | "Defense" | "Utility" | "Crafting"
}

interface PanelPlayerSkillsProps {
  skills?: Skill[]
}

const defaultSkills: Skill[] = [
  {
    id: "1",
    name: "Sword Mastery",
    description: "Increased proficiency with bladed weapons",
    level: 5,
    maxLevel: 10,
    icon: "🗡️",
    category: "Combat",
  },
  {
    id: "2",
    name: "Heavy Armor",
    description: "Ability to wear heavier armor with less penalty",
    level: 7,
    maxLevel: 10,
    icon: "🛡️",
    category: "Defense",
  },
  {
    id: "3",
    name: "Tactics",
    description: "Better positioning and battlefield awareness",
    level: 4,
    maxLevel: 10,
    icon: "📋",
    category: "Utility",
  },
  {
    id: "4",
    name: "Endurance",
    description: "Increased stamina and fatigue resistance",
    level: 6,
    maxLevel: 10,
    icon: "💚",
    category: "Defense",
  },
  {
    id: "5",
    name: "Marksmanship",
    description: "Improved accuracy with ranged weapons",
    level: 3,
    maxLevel: 10,
    icon: "🏹",
    category: "Combat",
  },
  {
    id: "6",
    name: "Blacksmithing",
    description: "Craft and repair weapons and armor",
    level: 2,
    maxLevel: 10,
    icon: "⚒️",
    category: "Crafting",
  },
  {
    id: "7",
    name: "Leadership",
    description: "Inspire and command allies in battle",
    level: 5,
    maxLevel: 10,
    icon: "👑",
    category: "Utility",
  },
  {
    id: "8",
    name: "Survival",
    description: "Navigate wilderness and find resources",
    level: 4,
    maxLevel: 10,
    icon: "🌲",
    category: "Utility",
  },
]

export function PanelPlayerSkills({ skills = defaultSkills }: PanelPlayerSkillsProps) {
  const getCategoryColor = (category: Skill["category"]) => {
    switch (category) {
      case "Combat":
        return "#c85a54"
      case "Defense":
        return "#5a8fc8"
      case "Utility":
        return "#8fc85a"
      case "Crafting":
        return "#c8a85a"
      default:
        return "#c89a4a"
    }
  }

  return (
    <div className={styles.skillsContainer}>
      <p>
        Skills slużą do pokazania jakie umiejętności posiada postać. Można je przekazywać innym postaciom ale nie są to
        aktywne abilities
      </p>
      <div className={styles.skillsGrid}>
        {skills.map((skill) => (
          <div
            key={skill.id}
            className={styles.skillItem}
          >
            <div className={styles.skillIcon}>
              <span className={styles.iconEmoji}>{skill.icon}</span>
              <div
                className={styles.categoryBadge}
                style={{ backgroundColor: getCategoryColor(skill.category) }}
              >
                {skill.category}
              </div>
            </div>
            <div className={styles.skillContent}>
              <div className={styles.skillHeader}>
                <h3 className={styles.skillName}>{skill.name}</h3>
                <div className={styles.skillLevel}>
                  <span className={styles.levelText}>
                    {skill.level}/{skill.maxLevel}
                  </span>
                  <div className={styles.levelBar}>
                    <div
                      className={styles.levelProgress}
                      style={{ width: `${(skill.level / skill.maxLevel) * 100}%` }}
                    />
                  </div>
                </div>
              </div>
              <p className={styles.skillDescription}>{skill.description}</p>
            </div>
          </div>
        ))}
      </div>
    </div>
  )
}
