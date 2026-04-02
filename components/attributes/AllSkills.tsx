"use client"
import Skill from "@/components/attributes/Skill"
import getIcon from "@/methods/functions/icons/getIcon"
import { useAllSKills } from "@/methods/hooks/attributes/composite/useAllSkills"
import styles from "./styles/AllSkills.module.css"

export default function AllSkills() {
  const { skills } = useAllSKills()

  return (
    <>
      <div className={styles.skillsContainer}>
        <div className={styles.skillsGrid}>
          {Object.values(skills).map((skill) => (
            <Skill
              key={skill.id}
              icon={getIcon(skill.image)}
              name={skill.name}
              value={0}
              maxValue={10}
              description={skill.description}
            />
          ))}
        </div>
      </div>
    </>
  )
}
