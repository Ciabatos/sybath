"use client"

import { useClickMapTile } from "@/methods/hooks/useClickTile"
import { mapTilesActionStatusAtom } from "@/store/atoms"
import { EMapTilesActionStatus } from "@/types/enumeration/MapTilesActionStatusEnum"
import { useAtom } from "jotai"

export function useMapTileClick() {
  const { setCoordinatesOnClick } = useClickMapTile()
  const [statusModalBottomCenterBar, setStatusModalBottomCenterBar] = useAtom(mapTilesActionStatusAtom)

  function handlieCLickOnMapTile(x: number, y: number) {
    setCoordinatesOnClick(x, y)

    //prettier-ignore
    if (statusModalBottomCenterBar === EMapTilesActionStatus.Inactive
     || statusModalBottomCenterBar === EMapTilesActionStatus.TileActionList) {
      setStatusModalBottomCenterBar(EMapTilesActionStatus.TileActionList)
    }
  }
  return { handlieCLickOnMapTile }
}
