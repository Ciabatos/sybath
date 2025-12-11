"use client"

import MapHandling from "@/components/map/MapHandling"
import { TDistrictsDistrictTypesRecordById } from "@/db/postgresMainDatabase/schemas/districts/districtTypes"
import { TWorldLandscapeTypesRecordById } from "@/db/postgresMainDatabase/schemas/world/landscapeTypes"
import { TWorldTerrainTypesRecordById } from "@/db/postgresMainDatabase/schemas/world/terrainTypes"
import { TJoinMapByXY } from "@/methods/functions/map/joinMap"
import { useRef, useState } from "react"
import type { ReactZoomPanPinchContentRef } from "react-zoom-pan-pinch"
import { TransformComponent, TransformWrapper } from "react-zoom-pan-pinch"
import style from "./styles/Map.module.css"

interface Props {
  joinedMap: TJoinMapByXY
  terrainTypes: TWorldTerrainTypesRecordById
  landscapeTypes: TWorldLandscapeTypesRecordById
  districtTypes: TDistrictsDistrictTypesRecordById
}

export default function MapWrapper({ joinedMap, terrainTypes, landscapeTypes, districtTypes }: Props) {
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
  Object.keys(joinedMap).forEach((key) => {
    const [x, y] = key.split(",").map(Number)
    if (x > maxX) maxX = x
    if (y > maxY) maxY = y
  })

  return (
    <>
      <div
        id='Map'
        className={style.map}
      >
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
          doubleClick={{ disabled: true }}
        >
          <TransformComponent wrapperStyle={{ width: "100%", height: "100%" }}>
            <div
              id='MapTiles'
              className={style.Tiles}
            >
              <MapHandling
                joinedMap={joinedMap}
                terrainTypes={terrainTypes}
                landscapeTypes={landscapeTypes}
                districtTypes={districtTypes}
              />
            </div>
          </TransformComponent>
        </TransformWrapper>
      </div>
    </>
  )
}
