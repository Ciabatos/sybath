import ModalBottomCenterBarHandling from "@/components/Modals/ModalBottomCenterBar/ModalBottomCenterBarHandling"
import { mapTilesActionStatusAtom } from "@/store/atoms"
import { EMapTilesActionStatus } from "@/types/enumeration/MapTilesActionStatusEnum"
import { useAtomValue } from "jotai"
import { useEffect, useState } from "react"
import { createPortal } from "react-dom"

export default function BottomCenterPortal() {
  const mapTilesActionStatus = useAtomValue(mapTilesActionStatusAtom)
  const [isMounted, setIsMounted] = useState(false)

  useEffect(() => {
    setIsMounted(true)
  }, [])

  if (!isMounted || mapTilesActionStatus === EMapTilesActionStatus.Inactive) {
    return null
  }

  return createPortal(<ModalBottomCenterBarHandling />, document.body)
}
