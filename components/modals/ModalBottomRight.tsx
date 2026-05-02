"use client"

import styles from "@/components/modals/styles/ModalBottomRight.module.css"
import { useModalBottomRight } from "@/methods/hooks/modals/useModalBottomRight"

export default function ModalBottomRight() {
  const { ModalBottomRight, resetModalBottomRight } = useModalBottomRight()

  if (!ModalBottomRight) return null

  return (
    <div className={styles.modalOverlay}>
      <div className={styles.modalContainer}>
        <ModalBottomRight closePanel={resetModalBottomRight} />
      </div>
    </div>
  )
}
