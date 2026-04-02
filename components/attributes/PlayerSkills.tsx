"use client"
import Skill from "@/components/attributes/Skill"
import { Button } from "@/components/ui/button"
import getIcon from "@/methods/functions/icons/getIcon"
import { usePlayerSkills } from "@/methods/hooks/attributes/composite/usePlayerSkills"
import { useState } from "react"
import styles from "./styles/PlayerSkills.module.css"

export function PlayerSkills() {
  const { combinedPlayerSkills } = usePlayerSkills()
  const [isShowingAllSkills, setIsShowingAllSkills] = useState(false)

  function showAllSkills() {
    setIsShowingAllSkills(!isShowingAllSkills)
  }

  return (
    <>
      <div className={styles.skillsContainer}>
        <p className={styles.description}>
          Skills slużą do pokazania jakie umiejętności posiada postać. Można je przekazywać innym postaciom ale nie są
          to aktywne abilities.
        </p>
        <Button onClick={showAllSkills}>Show All Skills</Button>
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
    </>
  )
}
