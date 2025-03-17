"use client"
import MapTilesClient from "@/components/MapTilesClient"
import { TMapLandscapeTypes } from "@/db/postgresMainDatabase/schemas/map/tables/landscapeTypes"
import type { TMapTerrainTypes } from "@/db/postgresMainDatabase/schemas/map/tables/terrainTypes"
import { TjoinedMapTile } from "@/methods/functions/joinMapTiles"
import { TransformComponent, TransformWrapper } from "react-zoom-pan-pinch"
import style from "./styles/Map.module.css"

interface Props {
  joinedMapTiles: Record<string, TjoinedMapTile>
  terrainTypes: Record<string, TMapTerrainTypes>
  landscapeTypes: Record<string, TMapLandscapeTypes>
}

export default function MapWrapper({ joinedMapTiles, terrainTypes, landscapeTypes }: Props) {
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
                landscapeTypes={landscapeTypes}></MapTilesClient>
            </div>
          </TransformComponent>
        </TransformWrapper>
      </div>
    </>
  )
}
