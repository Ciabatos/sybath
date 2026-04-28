"use client"

import styles from "@/components/modals/styles/ModalBottomLeft.module.css"
import { useModalBottomLeft } from "@/methods/hooks/modals/useModalBottomLeft"

export default function ModalBottomLeft() {
  const { ModalBottomLeft, resetModalBottomLeft } = useModalBottomLeft()

  if (!ModalBottomLeft) return null

  return (
    <div className={styles.modalOverlay}>
      <div className={styles.modalContainer}>
        <ModalBottomLeft closePanel={resetModalBottomLeft} />
      </div>
    </div>
  )
}
