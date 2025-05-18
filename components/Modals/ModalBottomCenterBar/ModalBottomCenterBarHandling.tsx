"use client"

import ModalMapTilesActionAbility from "@/components/Modals/ModalBottomCenterBar/ModalMapTilesActionAbility"
import ModalMapTilesActionGuardArea from "@/components/Modals/ModalBottomCenterBar/ModalMapTilesActionGuardArea"
import ModalMapTilesActionMovment from "@/components/Modals/ModalBottomCenterBar/ModalMapTilesActionMovment"
import ModalMapTilesCityActionBar from "@/components/Modals/ModalBottomCenterBar/ModalMapTilesCityActionBar"
import ModalMapTilesDistrictActionBar from "@/components/Modals/ModalBottomCenterBar/ModalMapTilesDistrictActionBar"
import ModalMapTilesPlayerActionBar from "@/components/Modals/ModalBottomCenterBar/ModalMapTilesPlayerActionBar"
import styles from "@/components/styles/Modals/ModalBottomCenterBar/ModalBottomCenterBarHandling.module.css"
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
