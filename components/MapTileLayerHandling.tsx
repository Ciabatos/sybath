"use client"

import MapTileLayerGuardAreaAction from "@/components/MapTileLayerGuardAreaAction"
import MapTileLayerMovementAction from "@/components/MapTileLayerMovmentAction"
import { TJoinedMapTile } from "@/methods/functions/joinMapTiles"
import { mapTilesActionStatusAtom, mapTilesGuardAreaAtom, mapTilesMovmentPathAtom } from "@/store/atoms"
import { EMapTilesActionStatus } from "@/types/enumeration/MapTilesActionStatusEnum"
import { useAtomValue } from "jotai"

interface Props {
  tile: TJoinedMapTile
}

export default function MapTileLayerHandling({ tile }: Props) {
  const mapTilesActionStatus = useAtomValue(mapTilesActionStatusAtom)
  const mapTilesMovmentPath = useAtomValue(mapTilesMovmentPathAtom)
  const mapTilesGuardArea = useAtomValue(mapTilesGuardAreaAtom)

  const isTileInMovementPath = mapTilesMovmentPath.some((pathTile) => pathTile.mapTile.x === tile.mapTile.x && pathTile.mapTile.y === tile.mapTile.y)
  const isTileInGuardArea = mapTilesGuardArea.some((pathTile) => pathTile.mapTile.x === tile.mapTile.x && pathTile.mapTile.y === tile.mapTile.y)

  if (!isTileInMovementPath && !isTileInGuardArea) {
    return null
  }

  switch (mapTilesActionStatus) {
    case EMapTilesActionStatus.MovementAction:
      return isTileInMovementPath ? <MapTileLayerMovementAction /> : null
    case EMapTilesActionStatus.UseAbilityAction:
      return isTileInMovementPath ? <MapTileLayerMovementAction /> : null
    case EMapTilesActionStatus.GuardAreaAction:
      return (
        <>
          {isTileInGuardArea && <MapTileLayerGuardAreaAction />}
          {isTileInMovementPath && <MapTileLayerMovementAction />}
        </>
      )
    default:
      return null
  }
}
