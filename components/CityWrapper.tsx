"use client"
import CityTilesClient from "@/components/CityTilesClient"
import ModalLeftTopHandling from "@/components/Modals/ModalLeftTop/ModalLeftTopHandling"
import { TMapLandscapeTypesById } from "@/db/postgresMainDatabase/schemas/map/tables/landscapeTypes"
import type { TMapTerrainTypesById } from "@/db/postgresMainDatabase/schemas/map/tables/terrainTypes"
import { TJoinedCityTilesById } from "@/methods/functions/joinCityTiles"
import { useEffect, useState } from "react"
import { createPortal } from "react-dom"
import { TransformComponent, TransformWrapper } from "react-zoom-pan-pinch"
import style from "./styles/Map.module.css"

interface Props {
  cityId: number
  joinedCityTiles: TJoinedCityTilesById
  terrainTypes: TMapTerrainTypesById
  landscapeTypes: TMapLandscapeTypesById
}

export default function CityWrapper({ cityId, joinedCityTiles, terrainTypes, landscapeTypes }: Props) {
  const [isMounted, setIsMounted] = useState(false)

  useEffect(() => {
    setIsMounted(true)
  }, [])

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
        {isMounted && createPortal(<ModalLeftTopHandling></ModalLeftTopHandling>, document.body)}
      </div>
    </>
  )
}
