// GENERATED CODE - DO NOT EDIT MANUALLY - modalCreateModal.hbs
"use client"

import styles from "@/components/modals/styles/ModalTopCenter.module.css"
import { useModalTopCenter } from "@/methods/hooks/modals/useModalTopCenter"

export default function ModalTopCenter() {
  const { ModalTopCenter, resetModalTopCenter } = useModalTopCenter()

  if (!ModalTopCenter) return null

  return (
    <div className={styles.modalOverlay}>
      <div className={styles.modalContainer}>
        <ModalTopCenter closePanel={resetModalTopCenter } />
      </div>
    </div>
  )
}