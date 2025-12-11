"use client"

import styles from "@/components/panels/styles/PanelActionBar.module.css"
import { usePlayerPositionMapTile } from "@/methods/hooks/mapTiles/composite/usePlayerPositionMapTile"
import { useModalBottomCenterBar } from "@/methods/hooks/modals/useModalBottomCenterBar"
import { usePlayerAbility } from "@/methods/hooks/players/composite/usePlayerAbility"
import { usePlayerAbilityRequirements } from "@/methods/hooks/players/composite/usePlayerAbilityRequirements"
import { useMutateActionTaskInProcess } from "@/methods/hooks/tasks/core/useMutateActionTaskInProcess"
import { useMapTileActions } from "@/methods/hooks/world/composite/useMapTileActions"
import { useMapTilesMovement } from "@/methods/hooks/world/composite/useMapTilesMovement"
import { EPanels } from "@/types/enumeration/EPanels"
import { useEffect } from "react"

export default function PanelActionAbility() {
  const { getClickedMapTile } = useMapTileActions()
  const { playerMapTile } = usePlayerPositionMapTile()
  const { selectMapTilesMovementPath, mapTilesMovementPathSet, doPlayerMovementAction } = useMapTilesMovement()
  const { mutateActionTaskInProcess } = useMutateActionTaskInProcess()
  const { selectedAbilityId, doPlayerAbility } = usePlayerAbility()
  const { setStatus } = useModalBottomCenterBar()
  const { abilityRequirements } = usePlayerAbilityRequirements()

  useEffect(() => {
    selectMapTilesMovementPath(playerMapTile, getClickedMapTile())
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [getClickedMapTile()])

  function handleButtonUseAbility() {
    mutateActionTaskInProcess(mapTilesMovementPathSet)
    doPlayerMovementAction()
    doPlayerAbility(selectedAbilityId, getClickedMapTile())
    setStatus(EPanels.PanelPlayerActionBar)
  }

  function handleButtonCancel() {
    setStatus(EPanels.PanelPlayerActionBar)
  }

  return (
    <div>
      <div className={styles.modalHeader}>
        <div className={styles.modalTitle}>
          <p>Select Options for Ability {abilityRequirements?.map((ability) => ability.requirement_type)}</p>
          <p>
            Use Ability on tile : {getClickedMapTile()?.tiles.x}, {getClickedMapTile()?.tiles.y}
          </p>
        </div>
        <div className={styles.actionGrid}>
          <button
            className={styles.actionButton}
            onClick={handleButtonUseAbility}
          >
            Use Ability
          </button>
          <button
            className={styles.actionButton}
            onClick={handleButtonCancel}
          >
            Cancel
          </button>
        </div>
      </div>
    </div>
  )
}
