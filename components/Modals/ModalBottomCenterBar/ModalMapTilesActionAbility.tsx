"use client"

import styles from "@/components/styles/Modals/ModalBottomCenterBar/ModalMapTilesActionGuardArea.module.css"
import { useActionMapTilesMovement } from "@/methods/hooks/useActionMapTilesMovement"
import { useActionPlayerAbility } from "@/methods/hooks/useActionPlayerAbility"
import { useFetchAbilityRequirements } from "@/methods/hooks/useFetchAbilityRequirements"
import { abilityRequirementsAtom, clickedTileAtom, mapTilesActionStatusAtom, selectedAbilityIdAtom } from "@/store/atoms"
import { EMapTilesActionStatus } from "@/types/enumeration/MapTilesActionStatusEnum"
import { useAtomValue, useSetAtom } from "jotai"
import { useEffect, useState } from "react"

export default function ModalMapTilesActionAbility() {
  const clickedTile = useAtomValue(clickedTileAtom)
  const abilityId = useAtomValue(selectedAbilityIdAtom)
  const [startingPoint] = useState(clickedTile)
  const setOpenModalBottomCenterBar = useSetAtom(mapTilesActionStatusAtom)
  const { actionMapTilesMovement } = useActionMapTilesMovement()
  const { handleUsePlayerAbility } = useActionPlayerAbility()

  useFetchAbilityRequirements(abilityId)
  const abilityRequirements = useAtomValue(abilityRequirementsAtom)

  useEffect(() => {
    if (startingPoint && clickedTile) {
      actionMapTilesMovement(startingPoint, clickedTile)
    }
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [clickedTile])

  const handleUseAbility = () => {
    handleUsePlayerAbility(abilityId, clickedTile)
    setOpenModalBottomCenterBar(EMapTilesActionStatus.Inactive)
  }

  const handleCancel = () => {
    setOpenModalBottomCenterBar(EMapTilesActionStatus.Inactive)
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
            onClick={handleUseAbility}>
            Use Ability
          </button>
          <button
            className={styles.actionButton}
            onClick={handleCancel}>
            Cancel
          </button>
        </div>
      </div>
    </div>
  )
}
