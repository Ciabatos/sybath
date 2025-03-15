"use client"

import MapTile from "@/components/MapTile"
import ModalBottomCenterBarHandling from "@/components/Modals/ModalBottomCenterBar/ModalBottomCenterBarHandling"
import ModalLeftTopHandling from "@/components/Modals/ModalLeftTop/ModalLeftTopHandling"
import type { TMapTerrainTypes } from "@/db/postgresMainDatabase/schemas/map/tables/terrainTypes"
import type { TjoinedMapTile } from "@/methods/functions/joinMapTilesServer"
import { useFetchMapTiles } from "@/methods/hooks/useFetchMapTiles"
import { useFetchMapTilesPlayerPostion } from "@/methods/hooks/useFetchMapTilesPlayerPosition"
import { useJoinMapTiles } from "@/methods/hooks/useJoinMapTiles"
import { joinedMapTilesAtom, mapTilesActionStatusAtom } from "@/store/atoms"
import { EMapTilesActionStatus } from "@/types/enumeration/MapTilesActionStatusEnum"
import { useAtomValue } from "jotai"
import { useSession } from "next-auth/react"
import { useEffect, useState } from "react"
import { createPortal } from "react-dom"

interface Props {
  joinedMapTiles: Record<string, TjoinedMapTile>
  terrainTypesById: Record<string, TMapTerrainTypes>
}

export default function MapTilesClient({ joinedMapTiles, terrainTypesById }: Props) {
  const session = useSession()
  console.log(session, "Client session")
  const [isMounted, setIsMounted] = useState(false)

  useEffect(() => {
    setIsMounted(true)
  }, [])

  useFetchMapTiles()
  useFetchMapTilesPlayerPostion()
  useJoinMapTiles(joinedMapTiles, terrainTypesById)
  const updatedTiles = useAtomValue(joinedMapTilesAtom) // NIE ZMIENIAC KOLEJNOSCI BO WYWALI ERROR Z HYDRATION!

  const mapTilesActionStatus = useAtomValue(mapTilesActionStatusAtom)

  return (
    <>
      {Object.entries(updatedTiles).map(([key, tile]) => (
        <MapTile
          key={key}
          tile={tile}
        />
      ))}
      {isMounted && mapTilesActionStatus != EMapTilesActionStatus.Inactive && createPortal(<ModalBottomCenterBarHandling />, document.body)}
      {isMounted && createPortal(<ModalLeftTopHandling></ModalLeftTopHandling>, document.body)}
    </>
  )
}
