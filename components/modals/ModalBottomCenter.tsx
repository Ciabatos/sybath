"use client"

import styles from "@/components/modals/styles/ModalBottomCenter.module.css"
import { useModalBottomCenterBar } from "@/methods/hooks/modals/useModalBottomCenterBar"

export default function ModalBottomCenter() {
  const { ModalBottomCenter, resetModalBottomCenterBar } = useModalBottomCenterBar()

  if (!ModalBottomCenter) return null

  return (
    <div className={styles.modalOverlay}>
      <div className={styles.modalContainer}>
        <ModalBottomCenter closePanel={resetModalBottomCenterBar} />
      </div>
    </div>
  )
}
