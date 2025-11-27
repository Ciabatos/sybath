"use client"

import PanelBackToMap from "@/components/panels/PanelBackToMap"

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