"use client"

import ModalMapTilesActionAbility from "@/components/modals/modalBottomCenterBar/ModalMapTilesActionAbility"
import ModalMapTilesActionGuardArea from "@/components/modals/modalBottomCenterBar/ModalMapTilesActionGuardArea"
import ModalMapTilesActionMovment from "@/components/modals/modalBottomCenterBar/ModalMapTilesActionMovment"
import ModalMapTilesCityActionBar from "@/components/modals/modalBottomCenterBar/ModalMapTilesCityActionBar"
import ModalMapTilesDistrictActionBar from "@/components/modals/modalBottomCenterBar/ModalMapTilesDistrictActionBar"
import ModalMapTilesPlayerActionBar from "@/components/modals/modalBottomCenterBar/ModalMapTilesPlayerActionBar"
import styles from "@/components/Modals/ModalBottomCenterBar/styles/ModalBottomCenterBarHandling.module.css"
import { mapTilesActionStatusAtom } from "@/store/atoms"
import { EMapTilesActionStatus } from "@/types/enumeration/MapTilesActionStatusEnum"
import { useAtomValue } from "jotai"

export default function ModalBottomCenterBarHandling() {
  const mapTilesActionStatus = useAtomValue(mapTilesActionStatusAtom)

  //prettier-ignore
  return (
	<>
    <div className={styles.modalOverlay}>
      <div className={styles.modalContainer}>
		{mapTilesActionStatus === EMapTilesActionStatus.PlayerActionList && <ModalMapTilesPlayerActionBar />}
		{mapTilesActionStatus === EMapTilesActionStatus.CityActionList && <ModalMapTilesCityActionBar />}
		{mapTilesActionStatus === EMapTilesActionStatus.DistrictActionList && <ModalMapTilesDistrictActionBar />}
		{mapTilesActionStatus === EMapTilesActionStatus.MovementAction && <ModalMapTilesActionMovment />}
		{mapTilesActionStatus === EMapTilesActionStatus.GuardAreaAction && <ModalMapTilesActionGuardArea />}
		{mapTilesActionStatus === EMapTilesActionStatus.UseAbilityAction && <ModalMapTilesActionAbility />}
    </div>
    </div>
	</>
  )
}
