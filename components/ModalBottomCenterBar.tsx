"use client"

import { openModalBottomCenterBarAtom } from "@/store/atoms"
import { useAtomValue } from "jotai"

import ModalMapTilesPlayerActionBar from "@/components/ModalMapTilesPlayerActionBar"
import styles from "@/components/styles/ModalBottomCenterBar.module.css"
import { EModalStatus } from "@/types/enumeration/ModalBottomCenterBarEnum"

export default function ModalBottomCenterBar() {
  const openModalBottomCenterBar = useAtomValue(openModalBottomCenterBarAtom)

  //prettier-ignore
  return (
	<>
    <div className={styles.modalOverlay}>
      <div className={styles.modalContainer}>
		{openModalBottomCenterBar === EModalStatus.PlayerActionBar && <ModalMapTilesPlayerActionBar />}
    </div>
    </div>
	</>
  )
}
