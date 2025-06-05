"use client"

import ModalMapTilesActionAbility from "@/components/modals/modalBottomCenterBar/ModalMapTilesActionAbility"
import ModalMapTilesActionGuardArea from "@/components/modals/modalBottomCenterBar/ModalMapTilesActionGuardArea"
import ModalMapTilesActionMovement from "@/components/modals/modalBottomCenterBar/ModalMapTilesActionMovement"
import ModalMapTilesCityActionBar from "@/components/modals/modalBottomCenterBar/ModalMapTilesCityActionBar"
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
		{mapTilesActionStatus === EMapTilesActionStatus.MovementAction && <ModalMapTilesActionMovement />}
		{mapTilesActionStatus === EMapTilesActionStatus.GuardAreaAction && <ModalMapTilesActionGuardArea />}
		{mapTilesActionStatus === EMapTilesActionStatus.UseAbilityAction && <ModalMapTilesActionAbility />}
    </div>
    </div>
	</>
  )
}
