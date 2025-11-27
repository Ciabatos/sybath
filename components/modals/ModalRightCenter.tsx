"use client"

import { PanelBuilding } from "@/components/panels/PanelBuilding"
import { PanelDistrict } from "@/components/panels/PanelDistrict"
import { PanelEmptyTilePanel } from "@/components/panels/PanelEmptyTilePanel"
import { useCityTilesActionStatus } from "@/methods/hooks/cities/composite/useCityTilesActionStatus"
import { useModal } from "@/methods/hooks/modals/useModal"

export function ModalRightCenter() {
  const { ActivePanel } = useModalRightCenter()

 if (!ActivePanel) return null

  return (
    <div className={styles.modalOverlay}>
      <div className={styles.modalContainer}>
        <ActivePanel />
      </div>
    </div>
  )
}