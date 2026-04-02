"use client"
import Skill from "@/components/attributes/Skill"
import { Button } from "@/components/ui/button"
import getIcon from "@/methods/functions/icons/getIcon"
import { useAllSKills } from "@/methods/hooks/attributes/composite/useAllSkills"
import { useModalRightCenter } from "@/methods/hooks/modals/useModalRightCenter"
import { X } from "lucide-react"
import styles from "./styles/AllSkills.module.css"

export default function AllSkills() {
  const { skills } = useAllSKills()
  const { resetModalRightCenter } = useModalRightCenter()

  function closeAllSkills() {
    resetModalRightCenter()
  }

  return (
    <>
      <div className={styles.skillsContainer}>
        <div className={styles.skillsGrid}>
          <Button
            onClick={() => closeAllSkills()}
            variant='ghost'
            size='icon'
          >
            <X />
          </Button>
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
