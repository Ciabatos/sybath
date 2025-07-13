"use client"

import styles from "@/components/portals/modals/ModalBottomCenterBar/styles/ModalActionBar.module.css"
import { useActionMapTilesMovement } from "@/methods/hooks/mapTiles/composite/useActionMapTilesMovement"
import { useMapTileActions } from "@/methods/hooks/mapTiles/composite/useMapTileActions"
import { useMapTilesActionStatus } from "@/methods/hooks/mapTiles/core/useMapTilesActionStatus"
import { usePlayerAbility } from "@/methods/hooks/playerAbility/composite/usePlayerAbility"
import { usePlayerAbilityRequirements } from "@/methods/hooks/playerAbility/composite/usePlayerAbilityRequirements"
import { useMutateActionTaskInProcess } from "@/methods/hooks/tasks/core/useMutateActionTaskInProcess"
import { useEffect, useState } from "react"

export default function ModalActionAbility() {
  const { clickedTile } = useMapTileActions()
  const [startingPoint] = useState(clickedTile)
  const { selectMapTilesMovementPath, mapTilesMovementPathSet, doPlayerMovementAction } = useActionMapTilesMovement()
  const { mutateActionTaskInProcess } = useMutateActionTaskInProcess()
  const { selectedAbilityId, doPlayerAbility } = usePlayerAbility()
  const { resetMapTilesActionStatus } = useMapTilesActionStatus()
  const { abilityRequirements } = usePlayerAbilityRequirements()

  useEffect(() => {
    selectMapTilesMovementPath(startingPoint, clickedTile)
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [clickedTile])

  function handleButtonUseAbility() {
    mutateActionTaskInProcess(mapTilesMovementPathSet)
    doPlayerMovementAction()
    doPlayerAbility(selectedAbilityId, clickedTile)
    resetMapTilesActionStatus()
  }

  function handleButtonCancel() {
    resetMapTilesActionStatus()
  }

  return (
    <div>
      <div className={styles.modalHeader}>
        <div className={styles.modalTitle}>
          <p>Select Options for Ability {abilityRequirements?.map((ability) => ability.requirement_type)}</p>
          <p>
            Use Ability on tile : {clickedTile?.mapTile.x}, {clickedTile?.mapTile.y}
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
