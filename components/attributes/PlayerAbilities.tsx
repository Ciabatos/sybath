"use client"
import Ability from "@/components/attributes/Ability"
import getIcon from "@/methods/functions/icons/getIcon"
import { usePlayerAbilities } from "@/methods/hooks/attributes/composite/usePlayerAbilities"
import styles from "./styles/PlayerAbilities.module.css"

export function PlayerAbilities() {
  const { combinedPlayerAbilities } = usePlayerAbilities()

  return (
    <div className={styles.abilitiesContainer}>
      <p>
        Abilities służą do używania, są to aktywne umiejętności, które można używać w walce lub produkcji i innych
        sytuacjach, ability powstaja jeżeli masz różne kombinacje skills, stats i knowledge.
      </p>
      <div className={styles.abilitiesGrid}>
        {combinedPlayerAbilities.map((playerAbility) => (
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
