"use client"

import styles from "@/components/modals/styles/ModalTopCenter.module.css"
import { useModalTopCenter } from "@/methods/hooks/modals/useModalTopCenter"

export default function ModalTopCenter() {
  const { ModalTopCenter, resetModalTopCeneter } = useModalTopCenter()

  if (!ModalTopCenter) return null

  return (
    <div className={styles.modalOverlay}>
      <div className={styles.modalContainer}>
        <ModalTopCenter closePanel={resetModalTopCeneter} />
      </div>
    </div>
  )
}
