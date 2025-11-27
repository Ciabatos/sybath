"use client"

import PanelCityActionBar from "@/components/panels/PanelCityActionBar"
import PanelPlayerActionBar from "@/components/panels/PanelPlayerActionBar"
import styles from "@/components/portals/modals/ModalBottomCenterBar/styles/ModalBottomCenterBarHandling.module.css"
import { useMapTilesActionStatus } from "@/methods/hooks/world/composite/useMapTilesActionStatus"

export default function ModalBottomCenterBar() {
  const { actualMapTilesActionStatus } = useMapTilesActionStatus()

  //prettier-ignore
  return (
	<>
    <div className={styles.modalOverlay}>
      <div className={styles.modalContainer}>
		{actualMapTilesActionStatus.PlayerActionList && <PanelPlayerActionBar />}
		{actualMapTilesActionStatus.CityActionList && <PanelCityActionBar />}
		{/* {actualMapTilesActionStatus.MovementAction && <ModalActionMovement />} */}
		{/* {actualMapTilesActionStatus.GuardAreaAction && <ModalActionGuardArea />} */}
		{/* {actualMapTilesActionStatus.UseAbilityAction && <ModalActionAbility />} */}
    </div>
    </div>
	</>
  )
}
