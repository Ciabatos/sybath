"use client"
import Ability from "@/components/attributes/Ability"
import getIcon from "@/methods/functions/icons/getIcon"
import { useOtherPlayerAbilities } from "@/methods/hooks/attributes/composite/useOtherPlayerAbilities"
import styles from "./styles/PlayerAbilities.module.css"

export function OtherPlayerAbilities() {
  const { combinedOtherPlayerAbilities } = useOtherPlayerAbilities()

  return (
    <div className={styles.abilitiesContainer}>
      <p>
        Abilities służą do używania, są to aktywne umiejętności, które można używać w walce lub produkcji i innych
        sytuacjach, ability powstaja jeżeli masz różne kombinacje skills, stats i knowledge.
      </p>
      <div className={styles.abilitiesGrid}>
        {combinedOtherPlayerAbilities.map((playerAbility) => (
          <Ability
            key={playerAbility.id}
            icon={getIcon(playerAbility.image)}
            name={playerAbility.name}
            value={playerAbility.value}
            maxValue={10}
            description={playerAbility.description}
          />
        ))}
      </div>
    </div>
  )
}
