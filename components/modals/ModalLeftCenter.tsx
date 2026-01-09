"use client"

import styles from "@/components/modals/styles/ModalLeftCenter.module.css"
import { useModalLeftCenter } from "@/methods/hooks/modals/useModalLeftCenter"

export function ModalLeftCenter() {
  const { ModalLeftCenter, resetModalLeftCenter } = useModalLeftCenter()

  if (!ModalLeftCenter) return null

  return (
    <div className={styles.modalOverlay}>
      <div className={styles.modalContainer}>
        <ModalLeftCenter closePanel={resetModalLeftCenter} />
      </div>
    </div>
  )
}
