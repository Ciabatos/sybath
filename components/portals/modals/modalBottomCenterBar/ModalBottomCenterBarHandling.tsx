"use client"

import ModalActionAbility from "@/components/portals/modals/modalBottomCenterBar/modalActionAbility/ModalActionAbility"
import ModalActionGuardArea from "@/components/portals/modals/modalBottomCenterBar/modalActionGuardArea/ModalActionGuardArea"
import ModalActionMovement from "@/components/portals/modals/modalBottomCenterBar/modalActionMovement/ModalActionMovement"
import ModalCityActionBar from "@/components/portals/modals/modalBottomCenterBar/modalCityActionBar/ModalCityActionBar"
import ModalPlayerActionBar from "@/components/portals/modals/modalBottomCenterBar/modalPlayerActionBar/ModalPlayerActionBar"
import styles from "@/components/portals/modals/ModalBottomCenterBar/styles/ModalBottomCenterBarHandling.module.css"
import { useMapTilesActionStatus } from "@/methods/hooks/mapTiles/core/useMapTilesActionStatus"

export default function ModalBottomCenterBarHandling() {
  const { actualMapTilesActionStatus } = useMapTilesActionStatus()

  //prettier-ignore
  return (
	<>
    <div className={styles.modalOverlay}>
      <div className={styles.modalContainer}>
		{actualMapTilesActionStatus.PlayerActionList && <ModalPlayerActionBar />}
		{actualMapTilesActionStatus.CityActionList && <ModalCityActionBar />}
		{actualMapTilesActionStatus.MovementAction && <ModalActionMovement />}
		{actualMapTilesActionStatus.GuardAreaAction && <ModalActionGuardArea />}
		{actualMapTilesActionStatus.UseAbilityAction && <ModalActionAbility />}
    </div>
    </div>
	</>
  )
}
