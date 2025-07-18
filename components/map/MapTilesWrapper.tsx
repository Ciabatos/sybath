"use client"

import MapTilesHandling from "@/components/map/MapTilesHandling"
import BottomCenterPortal from "@/components/portals/BottomCenterPortal"
import LeftTopPortal from "@/components/portals/LeftTopPortal"
import RightCenterPortal from "@/components/portals/RightCenterPoratl"
import { TMapLandscapeTypesById } from "@/db/postgresMainDatabase/schemas/map/landscapeTypes"
import type { TMapTerrainTypesById } from "@/db/postgresMainDatabase/schemas/map/terrainTypes"
import { TJoinedMapTile } from "@/methods/functions/joinMapTiles"
import { useRef, useState } from "react"
import type { ReactZoomPanPinchContentRef } from "react-zoom-pan-pinch"
import { TransformComponent, TransformWrapper } from "react-zoom-pan-pinch"
import style from "./styles/Map.module.css"

interface Props {
  joinedMapTiles: Record<string, TJoinedMapTile>
  terrainTypes: TMapTerrainTypesById
  landscapeTypes: TMapLandscapeTypesById
}

export default function MapTilesWrapper({ joinedMapTiles, terrainTypes, landscapeTypes }: Props) {
  const transformRef = useRef<ReactZoomPanPinchContentRef | null>(null)

  const [savedTransform] = useState(() => {
    if (typeof window !== "undefined") {
      const stored = localStorage.getItem(`MapZoomState`)
      if (stored) {
        return JSON.parse(stored)
      }
    }
    return { scale: 1, positionX: 0, positionY: 0 }
  })

  // Lepszy sposób na wyliczenie maxX i maxY
  let maxX = 0
  let maxY = 0
  Object.keys(joinedMapTiles).forEach((key) => {
    const [x, y] = key.split(",").map(Number)
    if (x > maxX) maxX = x
    if (y > maxY) maxY = y
  })

  return (
    <>
      <div
        id="Map"
        className={style.map}>
        <TransformWrapper
          ref={transformRef}
          initialScale={savedTransform.scale}
          initialPositionX={savedTransform.positionX}
          initialPositionY={savedTransform.positionY}
          onTransformed={({ state }) => {
            localStorage.setItem(
              "MapZoomState",
              JSON.stringify({
                scale: state.scale,
                positionX: state.positionX,
                positionY: state.positionY,
              }),
            )
          }}
          minScale={0.4}
          limitToBounds={false}
          doubleClick={{ disabled: true }}>
          <TransformComponent wrapperStyle={{ width: "100%", height: "100%" }}>
            <div
              id="MapTiles"
              className={style.Tiles}>
              <MapTilesHandling
                joinedMapTiles={joinedMapTiles}
                terrainTypes={terrainTypes}
                landscapeTypes={landscapeTypes}
              />
            </div>
          </TransformComponent>
        </TransformWrapper>
      </div>
      <BottomCenterPortal />
      <LeftTopPortal />
      <RightCenterPortal />
    </>
  )
}
