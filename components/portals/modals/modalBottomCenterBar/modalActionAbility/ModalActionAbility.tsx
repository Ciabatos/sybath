"use client"

import styles from "@/components/portals/modals/ModalBottomCenterBar/styles/ModalActionBar.module.css"
import { useActionMapTilesMovement } from "@/methods/hooks/mapTiles/composite/useActionMapTilesMovement"
import { useMapTileActions } from "@/methods/hooks/mapTiles/composite/useMapTileActions"
import { usePlayerPositionMapTile } from "@/methods/hooks/mapTiles/composite/usePlayerPositionMapTile"
import { useMapTilesActionStatus } from "@/methods/hooks/mapTiles/core/useMapTilesActionStatus"
import { usePlayerAbility } from "@/methods/hooks/playerAbility/composite/usePlayerAbility"
import { usePlayerAbilityRequirements } from "@/methods/hooks/playerAbility/composite/usePlayerAbilityRequirements"
import { useMutateActionTaskInProcess } from "@/methods/hooks/tasks/core/useMutateActionTaskInProcess"
import { useEffect } from "react"

export default function ModalActionAbility() {
  const { getClickedMapTile } = useMapTileActions()
  const { playerMapTile } = usePlayerPositionMapTile()
  const { selectMapTilesMovementPath, mapTilesMovementPathSet, doPlayerMovementAction } = useActionMapTilesMovement()
  const { mutateActionTaskInProcess } = useMutateActionTaskInProcess()
  const { selectedAbilityId, doPlayerAbility } = usePlayerAbility()
  const { newMapTilesActionStatus } = useMapTilesActionStatus()
  const { abilityRequirements } = usePlayerAbilityRequirements()

  useEffect(() => {
    selectMapTilesMovementPath(playerMapTile, getClickedMapTile())
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [getClickedMapTile()])

  function handleButtonUseAbility() {
    mutateActionTaskInProcess(mapTilesMovementPathSet)
    doPlayerMovementAction()
    doPlayerAbility(selectedAbilityId, getClickedMapTile())
    newMapTilesActionStatus.PlayerActionList()
  }

  function handleButtonCancel() {
    newMapTilesActionStatus.PlayerActionList()
  }

  return (
    <div>
      <div className={styles.modalHeader}>
        <div className={styles.modalTitle}>
          <p>Select Options for Ability {abilityRequirements?.map((ability) => ability.requirement_type)}</p>
          <p>
            Use Ability on tile : {getClickedMapTile()?.mapTile.x}, {getClickedMapTile()?.mapTile.y}
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
