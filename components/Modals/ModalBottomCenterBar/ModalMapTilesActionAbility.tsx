"use client"

import styles from "@/components/styles/Modals/ModalBottomCenterBar/ModalMapTilesActionGuardArea.module.css"
import { useActionMapTilesAbility } from "@/methods/hooks/playerMapTilesActions/useActionMapTilesAbility"

export default function ModalMapTilesActionAbility() {
  const { endingPoint, abilityRequirements, handleButtonUseAbility, handleButtonCancel } = useActionMapTilesAbility()

  return (
    <div>
      <div className={styles.modalHeader}>
        <div className={styles.modalTitle}>
          <p>Select Options for Ability {abilityRequirements?.map((ability) => ability.requirement_type)}</p>
          <p>
            Use Ability on tile : {endingPoint?.mapTile.x}, {endingPoint?.mapTile.y}
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
