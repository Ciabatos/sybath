"use client"
import MapTilesClient from "@/components/MapTilesClient"
import ModalBottomCenterBarHandling from "@/components/Modals/ModalBottomCenterBar/ModalBottomCenterBarHandling"
import ModalLeftTopHandling from "@/components/Modals/ModalLeftTop/ModalLeftTopHandling"
import { TMapLandscapeTypesById } from "@/db/postgresMainDatabase/schemas/map/tables/landscapeTypes"
import type { TMapTerrainTypesById } from "@/db/postgresMainDatabase/schemas/map/tables/terrainTypes"
import { TJoinedMapTile } from "@/methods/functions/joinMapTiles"
import { mapTilesActionStatusAtom } from "@/store/atoms"
import { EMapTilesActionStatus } from "@/types/enumeration/MapTilesActionStatusEnum"
import { useAtomValue } from "jotai"
import { useEffect, useState } from "react"
import { createPortal } from "react-dom"
import { TransformComponent, TransformWrapper } from "react-zoom-pan-pinch"
import style from "./styles/Map.module.css"

interface Props {
  joinedMapTiles: Record<string, TJoinedMapTile>
  terrainTypes: TMapTerrainTypesById
  landscapeTypes: TMapLandscapeTypesById
}

export default function MapWrapper({ joinedMapTiles, terrainTypes, landscapeTypes }: Props) {
  const [isMounted, setIsMounted] = useState(false)
  const mapTilesActionStatus = useAtomValue(mapTilesActionStatusAtom)

  useEffect(() => {
    setIsMounted(true)
  }, [])

  return (
    <>
      <div
        id="Map"
        className={style.map}>
        <TransformWrapper
          minScale={0.4}
          limitToBounds={false}
          doubleClick={{ disabled: true }}>
          <TransformComponent>
            <div
              id="Tiles"
              className={style.Tiles}>
              <MapTilesClient
                joinedMapTiles={joinedMapTiles}
                terrainTypes={terrainTypes}
                landscapeTypes={landscapeTypes}
              />
            </div>
          </TransformComponent>
        </TransformWrapper>
        {isMounted && mapTilesActionStatus != EMapTilesActionStatus.Inactive && createPortal(<ModalBottomCenterBarHandling />, document.body)}
        {isMounted && createPortal(<ModalLeftTopHandling></ModalLeftTopHandling>, document.body)}
      </div>
    </>
  )
}
