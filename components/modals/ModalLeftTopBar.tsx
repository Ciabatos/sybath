"use client"

import { useModalLeftTopBar } from "@/methods/hooks/modals/useModalLeftTopBar"
import styles from "@/components/modals/styles/ModalLeftTopBar.module.css"

export default function ModalLeftTopBar() {
  const { ActivePanel } = useModalLeftTopBar()

 if (!ActivePanel) return null

  return (
    <div className={styles.modalOverlay}>
      <div className={styles.modalContainer}>
        <ActivePanel />
      </div>
    </div>
  )
}