"use client"

import { useModalRightCenter } from "@/methods/hooks/modals/useModalRightCenter"
import styles from "@/components/modals/styles/ModalRightCenter.module.css"

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