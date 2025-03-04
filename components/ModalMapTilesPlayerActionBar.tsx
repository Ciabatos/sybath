"use client"

import styles from "./styles/ModalMapTilesPlayerActionBar.module.css"

interface Props {
  setIsModalMapTilesPlayerActionBarOpen: React.Dispatch<React.SetStateAction<boolean>>
}

export default function ModalMapTilesPlayerActionBar({ setIsModalMapTilesPlayerActionBarOpen }: Props) {
  const handleMove = () => {
    setIsModalMapTilesPlayerActionBarOpen(false)
  }

  const handleAttack = () => {
    setIsModalMapTilesPlayerActionBarOpen(false)
  }

  const handleInteract = () => {
    setIsModalMapTilesPlayerActionBarOpen(false)
  }

  const handleInspect = () => {
    setIsModalMapTilesPlayerActionBarOpen(false)
  }

  return (
    <div className={styles.modalOverlay}>
      <div className={styles.modalContainer}>
        <div className={styles.modalHeader}>
          <h3 className={styles.modalTitle}>Player Actions</h3>
        </div>

        <div className={styles.modalContent}>
          <p>Select an action to perform on this tile.</p>

          <div className={styles.actionGrid}>
            <button
              className={styles.actionButton}
              onClick={handleMove}>
              Move
            </button>
            <button
              className={styles.actionButton}
              onClick={handleAttack}>
              Interact
            </button>
            <button
              className={styles.actionButton}
              onClick={handleInteract}>
              Attack
            </button>
            <button
              className={styles.actionButton}
              onClick={handleInteract}>
              Guar Area
            </button>
            <button
              className={styles.actionButton}
              onClick={handleInspect}>
              Build
            </button>
            <button
              className={styles.actionButton}
              onClick={handleInspect}>
              Inspect
            </button>
          </div>
        </div>
      </div>
    </div>
  )
}
