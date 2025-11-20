"use client"

import CityHandling from "@/components/city/CityHandling"
import LeftTopPortal from "@/components/portals/LeftTopPortal"
import RightCenterPortal from "@/components/portals/RightCenterPoratl"
import TopCenterPortal from "@/components/portals/TopCenterPortal"
import { TMapLandscapeTypesById } from "@/db/postgresMainDatabase/schemas/map/landscapeTypes"
import type { TMapTerrainTypesById } from "@/db/postgresMainDatabase/schemas/map/terrainTypes"
import { TJoinCityByXY } from "@/methods/functions/map/joinCity"
import { useRef, useState } from "react"
import { ReactZoomPanPinchContentRef, TransformComponent, TransformWrapper } from "react-zoom-pan-pinch"
import style from "./styles/Map.module.css"

interface Props {
  cityId: number
  joinedCity: TJoinCityByXY
  terrainTypes: TMapTerrainTypesById
  landscapeTypes: TMapLandscapeTypesById
}

export default function CityWrapper({ cityId, joinedCity, terrainTypes, landscapeTypes }: Props) {
  const transformRef = useRef<ReactZoomPanPinchContentRef | null>(null)

  const [savedTransform] = useState(() => {
    if (typeof window !== "undefined") {
      const stored = localStorage.getItem(`City${cityId}ZoomState`)
      if (stored) {
        return JSON.parse(stored)
      }
    }
    return { scale: 1, positionX: 0, positionY: 0 }
  })

  // Lepszy sposób na wyliczenie maxX i maxY
  let maxX = 0
  let maxY = 0
  Object.keys(joinedCity).forEach((key) => {
    const [x, y] = key.split("_").map(Number)
    if (x > maxX) maxX = x
    if (y > maxY) maxY = y
  })

  return (
    <>
      <div
        id="City"
        className={style.map}>
        <TransformWrapper
          ref={transformRef}
          initialScale={savedTransform.scale}
          initialPositionX={savedTransform.positionX}
          initialPositionY={savedTransform.positionY}
          onTransformed={({ state }) => {
            localStorage.setItem(
              `City${cityId}ZoomState`,
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
              id="CityTiles"
              className={style.Tiles}>
              <CityHandling
                cityId={cityId}
                joinedCity={joinedCity}
                terrainTypes={terrainTypes}
                landscapeTypes={landscapeTypes}
              />
            </div>
          </TransformComponent>
        </TransformWrapper>
        <TopCenterPortal />
        <LeftTopPortal />
        <RightCenterPortal />
      </div>
    </>
  )
}
