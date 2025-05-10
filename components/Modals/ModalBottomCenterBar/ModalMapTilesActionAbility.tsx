"use client"

import styles from "@/components/styles/Modals/ModalBottomCenterBar/ModalMapTilesActionGuardArea.module.css"
import { useFetchAbilityRequirements } from "@/methods/hooks/fetchers/useFetchAbilityRequirements"
import { useActionMapTilesMovement } from "@/methods/hooks/useActionMapTilesMovement"
import { usePlayerAbility } from "@/methods/hooks/usePlayerAbility"
import { abilityRequirementsAtom, clickedTileAtom, selectedAbilityIdAtom } from "@/store/atoms"
import { useAtomValue } from "jotai"
import { useEffect, useState } from "react"

export default function ModalMapTilesActionAbility() {
  const clickedTile = useAtomValue(clickedTileAtom)
  const abilityId = useAtomValue(selectedAbilityIdAtom)
  const [startingPoint] = useState(clickedTile)
  const { actionMapTilesMovement } = useActionMapTilesMovement()
  const { handleUsePlayerAbility, handleCancelPlayerAbility } = usePlayerAbility()

  useFetchAbilityRequirements(abilityId)
  const abilityRequirements = useAtomValue(abilityRequirementsAtom)

  useEffect(() => {
    if (startingPoint && clickedTile) {
      actionMapTilesMovement(startingPoint, clickedTile)
    }
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [clickedTile])

  const handleButtonUseAbility = () => {
    handleUsePlayerAbility(abilityId, clickedTile)
  }

  const handleButtonCancel = () => {
    handleCancelPlayerAbility()
  }

  return (
    <div>
      <div className={styles.modalHeader}>
        <div className={styles.modalTitle}>
          <p>Select Options for Ability {abilityRequirements.map((ability) => ability.requirement_type)}</p>
          <p>
            Use Ability on tile : {clickedTile?.x}, {clickedTile?.y}
          </p>
        </div>
        <div className={styles.actionGrid}>
          <button
            className={styles.actionButton}
            onClick={handleButtonUseAbility}>
            Use Ability
          </button>
          <button
            className={styles.actionButton}
            onClick={handleButtonCancel}>
            Cancel
          </button>
        </div>
      </div>
    </div>
  )
}
