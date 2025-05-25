"use client"

import CityTilesClient from "@/components/city/CityTilesClient"
import LeftTopPortal from "@/components/modals/LeftTopPortal"
import RightCenterPortal from "@/components/modals/RightCenterPoratl"
import TopCenterPortal from "@/components/modals/TopCenterPortal"
import { TMapLandscapeTypesById } from "@/db/postgresMainDatabase/schemas/map/tables/landscapeTypes"
import type { TMapTerrainTypesById } from "@/db/postgresMainDatabase/schemas/map/tables/terrainTypes"
import { TJoinedCityTilesById } from "@/methods/functions/joinCityTiles"
import { useEffect, useRef, useState } from "react"
import { ReactZoomPanPinchContentRef, TransformComponent, TransformWrapper } from "react-zoom-pan-pinch"
import style from "./styles/Map.module.css"

interface Props {
  cityId: number
  joinedCityTiles: TJoinedCityTilesById
  terrainTypes: TMapTerrainTypesById
  landscapeTypes: TMapLandscapeTypesById
}

export default function CityWrapper({ cityId, joinedCityTiles, terrainTypes, landscapeTypes }: Props) {
  const transformRef = useRef<ReactZoomPanPinchContentRef | null>(null)
  const [savedTransform, setSavedTransform] = useState({ scale: 1, positionX: 0, positionY: 0 })

  useEffect(() => {
    if (typeof window !== "undefined") {
      const stored = localStorage.getItem(`City${cityId}ZoomState`)
      if (stored) {
        setSavedTransform(JSON.parse(stored))
      }
    }
  }, [cityId])

  // Lepszy sposób na wyliczenie maxX i maxY
  let maxX = 0
  let maxY = 0
  Object.keys(joinedCityTiles).forEach((key) => {
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
              <CityTilesClient
                cityId={cityId}
                joinedCityTiles={joinedCityTiles}
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
