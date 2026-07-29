// GENERATED CODE - DO NOT EDIT MANUALLY - modalCreateModal.hbs
"use client"

import styles from "@/components/modals/styles/ModalBottomCenter.module.css"
import { useModalBottomCenter } from "@/methods/hooks/modals/useModalBottomCenter"

export default function ModalBottomCenter() {
  const { ModalBottomCenter, resetModalBottomCenter } = useModalBottomCenter()

  if (!ModalBottomCenter) return null

  return (
    <div className={styles.modalOverlay}>
      <div className={styles.modalContainer}>
        <ModalBottomCenter closePanel={resetModalBottomCenter } />
      </div>
    </div>
  )
}