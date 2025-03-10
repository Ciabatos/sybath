"use client"

import { useMapTileClick } from "@/methods/hooks/useMapTileClick"
import { mapTilesActionStatusAtom } from "@/store/atoms"
import { EMapTilesActionStatus } from "@/types/enumeration/MapTilesActionStatusEnum"
import { useAtom } from "jotai"

export function useMapTileClickHandling() {
  const { setCoordinatesOnClick } = useMapTileClick()
  const [statusModalBottomCenterBar, setStatusModalBottomCenterBar] = useAtom(mapTilesActionStatusAtom)

  function handleCLickOnMapTile(x: number, y: number) {
    setCoordinatesOnClick(x, y)

    //prettier-ignore
    if (statusModalBottomCenterBar === EMapTilesActionStatus.Inactive
     || statusModalBottomCenterBar === EMapTilesActionStatus.TileActionList) {
      setStatusModalBottomCenterBar(EMapTilesActionStatus.TileActionList)
    }
  }
  return { handleCLickOnMapTile }
}
