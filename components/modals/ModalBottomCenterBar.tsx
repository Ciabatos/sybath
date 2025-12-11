"use client"

import styles from "@/components/modals/styles/ModalBottomCenterBar.module.css"
import { useModalBottomCenterBar } from "@/methods/hooks/modals/useModalBottomCenterBar"

export default function ModalBottomCenterBar() {
  const { ActivePanel } = useModalBottomCenterBar()

  if (!ActivePanel) return null

  return (
    <div className={styles.modalOverlay}>
      <div className={styles.modalContainer}>
        <ActivePanel />
      </div>
    </div>
  )
}
