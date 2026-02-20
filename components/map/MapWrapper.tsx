"use client"

import MapLayerHandling from "@/components/map/layers/mapLayers/MapLayerHandling"
import MapHandling from "@/components/map/MapHandling"
import { useMapHandling } from "@/methods/hooks/world/composite/useMapHandling"
import { useRef, useState } from "react"
import type { ReactZoomPanPinchContentRef } from "react-zoom-pan-pinch"
import { TransformComponent, TransformWrapper } from "react-zoom-pan-pinch"
import style from "./styles/Map.module.css"

export default function MapWrapper() {
  const { mapId, mapTiles } = useMapHandling()
  const transformRef = useRef<ReactZoomPanPinchContentRef | null>(null)

  const [savedTransform] = useState(() => {
    if (typeof window !== "undefined") {
      const stored = localStorage.getItem(`Map${mapId}ZoomState`)
      if (stored) {
        return JSON.parse(stored)
      }
    }
    return { scale: 1, positionX: 0, positionY: 0 }
  })

  // Lepszy sposób na wyliczenie maxX i maxY
  let maxX = 0
  let maxY = 0
  Object.keys(mapTiles).forEach((key) => {
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
              `Map${mapId}ZoomState`,
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
              <MapHandling />
              <MapLayerHandling />
            </div>
          </TransformComponent>
        </TransformWrapper>
      </div>
    </>
  )
}
