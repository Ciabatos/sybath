"use client"
import style from "./styles/Map.module.css"
import { TransformWrapper, TransformComponent } from "react-zoom-pan-pinch"
import type { TjoinedMapTilesObj } from "./MapTilesServer"
import MapTilesClient from "@/components/MapTilesClient"

export default function MapWrapper({ joinedMapTiles }: { joinedMapTiles: Record<string, TjoinedMapTilesObj> }) {
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
              <MapTilesClient joinedMapTiles={joinedMapTiles}></MapTilesClient>
            </div>
          </TransformComponent>
        </TransformWrapper>
      </div>
    </>
  )
}
