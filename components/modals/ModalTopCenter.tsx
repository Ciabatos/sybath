"use client"

import { useModalTopCenter } from "@/methods/hooks/modals/useModalTopCenter"
import styles from "@/components/modals/styles/ModalTopCenter.module.css"

export default function ModalTopCenter() {
  const { ActivePanel } = useModalTopCenter()

 if (!ActivePanel) return null

  return (
    <div className={styles.modalOverlay}>
      <div className={styles.modalContainer}>
        <ActivePanel />
      </div>
    </div>
  )
}