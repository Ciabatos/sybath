"use client"

import styles from "@/components/modals/styles/ModalTopCenterBar.module.css"
import { useModalTopCenterBar } from "@/methods/hooks/modals/useModalTopCenterBar"

export default function ModalTopCenterBar() {
  const { ModalTopCenterBar, resetModalTopCenterBar } = useModalTopCenterBar()

  if (!ModalTopCenterBar) return null

  return (
    <div className={styles.modalOverlay}>
      <div className={styles.modalContainer}>
        <ModalTopCenterBar closePanel={resetModalTopCenterBar} />
      </div>
    </div>
  )
}
