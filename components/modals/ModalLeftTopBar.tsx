"use client"

import PanelPlayerPanel from "@/components/panels/PanelPlayerPanel"

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