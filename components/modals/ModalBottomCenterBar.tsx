"use client"

import styles from "@/components/portals/modals/ModalBottomCenterBar/styles/ModalBottomCenterBarHandling.module.css"
import { useModal } from "@/methods/hooks/modals/useModal"

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