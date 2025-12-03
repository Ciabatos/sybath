"use client"

import styles from "@/components/modals/styles/ModalRightCenter.module.css"
import { useModalRightCenter } from "@/methods/hooks/modals/useModalRightCenter"

export function ModalRightCenter() {
  const { ActivePanel } = useModalRightCenter()

  if (!ActivePanel) return null

  return (
    <div className={styles.modalOverlay}>
      <div className={styles.modalContainer}>
        <ActivePanel />
      </div>
    </div>
  )
}
