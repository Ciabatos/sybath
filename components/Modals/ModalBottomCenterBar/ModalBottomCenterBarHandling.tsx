"use client"

import ModalMapTilesPlayerActionBar from "@/components/Modals/ModalBottomCenterBar/ModalMapTilesPlayerActionBar"
import ModalMapTilesPlayerActionMovment from "@/components/Modals/ModalBottomCenterBar/ModalMapTilesPlayerActionMovment"
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
		{mapTilesActionStatus === EMapTilesActionStatus.TileActionList && <ModalMapTilesPlayerActionBar />}
		{mapTilesActionStatus === EMapTilesActionStatus.MovementAction && <ModalMapTilesPlayerActionMovment />}
    </div>
    </div>
	</>
  )
}
