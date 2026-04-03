"use client"
import Ability from "@/components/attributes/Ability"
import { Button } from "@/components/ui/button"
import getIcon from "@/methods/functions/icons/getIcon"
import { usePlayerAbilities } from "@/methods/hooks/attributes/composite/usePlayerAbilities"
import { useModalRightCenter } from "@/methods/hooks/modals/useModalRightCenter"
import { EPanelsRightCenter } from "@/types/enumeration/EPanelsRightCenter"
import styles from "./styles/PlayerAbilities.module.css"

export function PlayerAbilities() {
  const { combinedPlayerAbilities } = usePlayerAbilities()
  const { openModalRightCenter } = useModalRightCenter()

  function showAllAbilities() {
    openModalRightCenter(EPanelsRightCenter.AllAbilities)
  }

  return (
    <div className={styles.abilitiesContainer}>
      <p className={styles.description}>
        Abilities służą do używania, są to aktywne umiejętności, które można używać w walce lub produkcji i innych
        sytuacjach. Ability powstają jeżeli masz różne kombinacje skills, stats i knowledge.
      </p>
      <Button onClick={showAllAbilities}>Show All Abilities</Button>
      <div className={styles.abilitiesGrid}>
        {combinedPlayerAbilities.map((playerAbility) => (
          <Ability
            key={playerAbility.id}
            icon={getIcon(playerAbility.image)}
            name={playerAbility.name}
            description={playerAbility.description}
            value={playerAbility.value}
          />
        ))}
      </div>
    </div>
  )
}
