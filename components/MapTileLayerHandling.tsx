"use client"

import MapTileLayerMovementAction from "@/components/MapTileLayerMovmentAction"
import { TjoinedMapTile } from "@/methods/functions/joinMapTilesServer"
import { mapTilesActionStatusAtom, mapTilesMovmentPathAtom } from "@/store/atoms"
import { EMapTilesActionStatus } from "@/types/enumeration/MapTilesActionStatusEnum"
import { useAtomValue } from "jotai"

interface Props {
  tile: TjoinedMapTile
}

export default function MapTileLayerHandling({ tile }: Props) {
  const mapTilesActionStatus = useAtomValue(mapTilesActionStatusAtom)
  const mapTilesMovmentPath = useAtomValue(mapTilesMovmentPathAtom)

  const isTileInMovementPath = mapTilesMovmentPath.some((pathTile) => pathTile.id === tile.id)

  if (!isTileInMovementPath) {
    return null
  }

  return mapTilesActionStatus === EMapTilesActionStatus.MovementAction ? <MapTileLayerMovementAction /> : null
}
