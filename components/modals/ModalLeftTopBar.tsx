"use client"

import styles from "@/components/modals/styles/ModalLeftTopBar.module.css"
import { useModalLeftTopBar } from "@/methods/hooks/modals/useModalLeftTopBar"

export default function ModalLeftTopBar() {
  const { ModalLeftTopBar } = useModalLeftTopBar()

  if (!ModalLeftTopBar) return null

  return (
    <div className={styles.modalOverlay}>
      <div className={styles.modalContainer}>
        <ModalLeftTopBar />
      </div>
    </div>
  )
}
