"use client"

import MapTile from "@/components/MapTile"
import ModalBottomCenterBarHandling from "@/components/Modals/ModalBottomCenterBar/ModalBottomCenterBarHandling"
import ModalLeftTopHandling from "@/components/Modals/ModalLeftTop/ModalLeftTopHandling"
import { TMapLandscapeTypes } from "@/db/postgresMainDatabase/schemas/map/tables/landscapeTypes"
import type { TMapTerrainTypes } from "@/db/postgresMainDatabase/schemas/map/tables/terrainTypes"
import { TjoinedMapTile } from "@/methods/functions/joinMapTiles"
import { useFetchMapTiles } from "@/methods/hooks/useFetchMapTiles"
import { useFetchPlayerVisibleMapData } from "@/methods/hooks/useFetchPlayerVisibleMapData"
import { useJoinMapTiles } from "@/methods/hooks/useJoinMapTiles"
import { joinedMapTilesAtom, mapTilesActionStatusAtom } from "@/store/atoms"
import { EMapTilesActionStatus } from "@/types/enumeration/MapTilesActionStatusEnum"
import { useAtomValue } from "jotai"
import { useHydrateAtoms } from "jotai/utils"
import { useSession } from "next-auth/react"
import { useEffect, useState } from "react"
import { createPortal } from "react-dom"

interface Props {
  joinedMapTiles: Record<string, TjoinedMapTile>
  terrainTypes: Record<string, TMapTerrainTypes>
  landscapeTypes: Record<string, TMapLandscapeTypes>
}

export default function MapTilesClient({ joinedMapTiles, terrainTypes, landscapeTypes }: Props) {
  const session = useSession()
  console.log(session, "Client session")

  const [isMounted, setIsMounted] = useState(false)
  const mapTilesActionStatus = useAtomValue(mapTilesActionStatusAtom)

  useEffect(() => {
    setIsMounted(true)
  }, [])

  useHydrateAtoms([[joinedMapTilesAtom, joinedMapTiles]])

  const updatedTiles = useAtomValue(joinedMapTilesAtom)

  useFetchMapTiles()
  useFetchPlayerVisibleMapData()
  useJoinMapTiles(terrainTypes, landscapeTypes)

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
