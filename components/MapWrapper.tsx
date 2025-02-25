"use client"
import style from "./styles/Map.module.css"
import { TransformWrapper, TransformComponent } from "react-zoom-pan-pinch"
import MapTilesClient from "@/components/MapTilesClient"
import type { TMapTerrainTypes } from "@/db/postgresMainDatabase/schemas/map/tables/mapTerrainTypes"
import type { TjoinedMapTile } from "@/methods/functions/joinMapTilesClient"

interface Props {
  joinedMapTiles: Record<string, TjoinedMapTile>
  terrainTypesById: Record<string, TMapTerrainTypes>
}

export default function MapWrapper({ joinedMapTiles, terrainTypesById }: Props) {
  return (
    <>
      <div
        id="Map"
        className={`${style.map} `}>
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
