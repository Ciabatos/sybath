"use client"
import Skill from "@/components/attributes/Skill"
import { Button } from "@/components/ui/button"
import getIcon from "@/methods/functions/icons/getIcon"
import { useAllSKills } from "@/methods/hooks/attributes/composite/useAllSkills"
import { useModalRightCenter } from "@/methods/hooks/modals/useModalRightCenter"
import { X } from "lucide-react"

export default function AllSkills() {
  const { allSkills } = useAllSKills()
  const { resetModalRightCenter } = useModalRightCenter()

  function closeAllSkills() {
    resetModalRightCenter()
  }

  return (
    <>
      <div>
        <Button
          onClick={() => closeAllSkills()}
          variant='ghost'
          size='icon'
        >
          <X />
        </Button>
        {Object.values(allSkills).map((skill) => (
          <Skill
            key={skill.id}
            icon={getIcon(skill.image)}
            name={skill.name}
            value={skill.value}
            maxValue={10}
            description={skill.description}
          />
        ))}
      </div>
    </>
  )
}
