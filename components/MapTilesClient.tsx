"use client"

import type { TMapTerrainTypes } from "@/db/postgresMainDatabase/schemas/map/tables/mapTerrainTypes"
import { TMapsFieldsPlayerPosition } from "@/db/postgresMainDatabase/schemas/map/views/mapsFieldsPlayerPosition"
import type { TjoinedMapTile } from "@/methods/functions/joinMapTilesServer"
import { useFetchMapTiles } from "@/methods/hooks/useFetchMapTiles"
import { useJoinMapTiles } from "@/methods/hooks/useJoinMapTiles"
import { joinedMapTilesAtom, openModalBottomCenterBarAtom } from "@/store/atoms"
import { useAtomValue } from "jotai"
// import { useSession } from "next-auth/react"
import MapTile from "@/components/MapTile"
import ModalBottomCenterBar from "@/components/ModalBottomCenterBar"
import { EModalStatus } from "@/types/enumeration/ModalBottomCenterBarEnum"
import { createPortal } from "react-dom"

interface Props {
  joinedMapTiles: Record<string, TjoinedMapTile>
  terrainTypesById: Record<string, TMapTerrainTypes>
  playerPositionById?: Record<string, TMapsFieldsPlayerPosition>
}

export default function MapTilesClient({ joinedMapTiles, terrainTypesById, playerPositionById }: Props) {
  // const session = useSession()

  useFetchMapTiles()
  useJoinMapTiles(joinedMapTiles, terrainTypesById, playerPositionById)
  const updatedTiles = useAtomValue(joinedMapTilesAtom) // NIE ZMIENIAC KOLEJNOSCI BO WYWALI ERROR Z HYDRATION!

  const openModalBottomCenterBar = useAtomValue(openModalBottomCenterBarAtom)

  return (
    <>
      {Object.entries(updatedTiles).map(([key, tile]) => (
        <MapTile
          key={key}
          tile={tile}
        />
      ))}
      {openModalBottomCenterBar != EModalStatus.Inactive && createPortal(<ModalBottomCenterBar />, document.body)}
    </>
  )
}
