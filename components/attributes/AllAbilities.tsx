"use client"
import Ability from "@/components/attributes/Ability"
import { Button } from "@/components/ui/button"
import getIcon from "@/methods/functions/icons/getIcon"
import { useAllAbilities } from "@/methods/hooks/attributes/composite/useAllAbilities"
import { useModalRightCenter } from "@/methods/hooks/modals/useModalRightCenter"
import { X } from "lucide-react"
import styles from "./styles/AllAbilities.module.css"

export default function AllAbilities() {
  const { resetModalRightCenter } = useModalRightCenter()
  const { allAbilities } = useAllAbilities()

  function closeAllAbilities() {
    resetModalRightCenter()
  }

  return (
    <>
      <div className={styles.allAbilitiesContainer}>
        <div>
          {Object.values(allAbilities).map((ability) => (
            <Ability
              key={ability.id}
              icon={getIcon(ability.image)}
              name={ability.name}
              description={ability.description}
              value={ability.value}
            />
          ))}
        </div>
        <Button
          onClick={() => closeAllAbilities()}
          variant='ghost'
          size='icon'
        >
          <X />
        </Button>
      </div>
    </>
  )
}
