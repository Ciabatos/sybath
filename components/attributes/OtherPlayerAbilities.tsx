"use client"
import Ability from "@/components/attributes/Ability"
import getIcon from "@/methods/functions/icons/getIcon"
import { useOtherPlayerAbilities } from "@/methods/hooks/attributes/composite/useOtherPlayerAbilities"
import { useModalRightCenter } from "@/methods/hooks/modals/useModalRightCenter"
import styles from "./styles/PlayerAbilities.module.css"

export function OtherPlayerAbilities() {
  const { combinedOtherPlayerAbilities } = useOtherPlayerAbilities()
  const { openModalRightCenter } = useModalRightCenter()

  return (
    <div className={styles.abilitiesContainer}>
      <p className={styles.description}>
        Abilities służą do używania, są to aktywne umiejętności, które można używać w walce lub produkcji i innych
        sytuacjach. Ability powstają jeżeli masz różne kombinacje skills, stats i knowledge.
      </p>
      <div className={styles.abilitiesGrid}>
        {combinedOtherPlayerAbilities.map((playerAbility) => (
          <Ability
            key={playerAbility.id}
            icon={getIcon(playerAbility.image)}
            name={playerAbility.name}
            description={playerAbility.description}
            value={playerAbility.value}
            disabled={true}
          />
        ))}
      </div>
    </div>
  )
}
