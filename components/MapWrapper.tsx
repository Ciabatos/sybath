"use client"
import MapTilesClient from "@/components/MapTilesClient"
import type { TMapTerrainTypes } from "@/db/postgresMainDatabase/schemas/map/tables/terrainTypes"
import type { TjoinedMapTile } from "@/methods/functions/joinMapTilesServer"
import { TransformComponent, TransformWrapper } from "react-zoom-pan-pinch"
import style from "./styles/Map.module.css"

interface Props {
  joinedMapTiles: Record<string, TjoinedMapTile>
  terrainTypesById: Record<string, TMapTerrainTypes>
}

export default function MapWrapper({ joinedMapTiles, terrainTypesById }: Props) {
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
                terrainTypesById={terrainTypesById}></MapTilesClient>
            </div>
          </TransformComponent>
        </TransformWrapper>
      </div>
    </>
  )
}
