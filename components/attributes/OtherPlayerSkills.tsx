"use client"
import Skill from "@/components/attributes/Skill"
import getIcon from "@/methods/functions/icons/getIcon"
import { useOtherPlayerSkills } from "@/methods/hooks/attributes/composite/useOtherPlayerSkills"
import styles from "./styles/PlayerSkills.module.css"

export function OtherPlayerSkills() {
  const { combinedOtherPlayerSkills } = useOtherPlayerSkills()

  return (
    <div className={styles.skillsContainer}>
      <p>
        Skills slużą do pokazania jakie umiejętności posiada postać. Można je przekazywać innym postaciom ale nie są to
        aktywne abilities
      </p>
      <div className={styles.skillsGrid}>
        {combinedOtherPlayerSkills.map((playerSkill) => (
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
