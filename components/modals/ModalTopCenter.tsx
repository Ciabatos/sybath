"use client"

import styles from "@/components/modals/styles/ModalTopCenter.module.css"
import { useModalTopCenter } from "@/methods/hooks/modals/useModalTopCenter"

export default function ModalTopCenter() {
  const { ModalTopCenterPanel, resetModalTopCeneter } = useModalTopCenter()

  if (!ModalTopCenterPanel) return null

  return (
    <div className={styles.modalOverlay}>
      <div className={styles.modalContainer}>
        <ModalTopCenterPanel closePanel={resetModalTopCeneter} />
      </div>
    </div>
  )
}
