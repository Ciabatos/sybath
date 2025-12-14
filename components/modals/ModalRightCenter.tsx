"use client"

import styles from "@/components/modals/styles/ModalRightCenter.module.css"
import { useModalRightCenter } from "@/methods/hooks/modals/useModalRightCenter"

export function ModalRightCenter() {
  const { ModalRightCenter, resetModalRightCenter } = useModalRightCenter()

  if (!ModalRightCenter) return null

  return (
    <div className={styles.modalOverlay}>
      <div className={styles.modalContainer}>
        <ModalRightCenter closePanel={resetModalRightCenter} />
      </div>
    </div>
  )
}
