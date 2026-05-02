"use client"

import MapLayerHandling from "@/components/map/layers/mapLayers/MapLayerHandling"
import MapHandling from "@/components/map/MapHandling"
import { useMapHandling } from "@/methods/hooks/world/composite/useMapHandling"
import { useEffect, useRef, useState } from "react"
import type { ReactZoomPanPinchContentRef } from "react-zoom-pan-pinch"
import { TransformComponent, TransformWrapper } from "react-zoom-pan-pinch"
import style from "./styles/Map.module.css"

const DEFAULT_TRANSFORM = { scale: 1, positionX: 0, positionY: 0 }

export default function MapWrapper() {
  const { mapId, mapTiles } = useMapHandling()
  const transformRef = useRef<ReactZoomPanPinchContentRef | null>(null)

  // Always start with defaults — matches the server render
  const [savedTransform, setSavedTransform] = useState(DEFAULT_TRANSFORM)
  const [hydrated, setHydrated] = useState(false)

  // After mount, read localStorage and update if needed
  useEffect(() => {
    const stored = localStorage.getItem(`Map${mapId}ZoomState`)
    if (stored) {
      try {
        setSavedTransform(JSON.parse(stored))
      } catch {
        // ignore malformed data
      }
    }
    setHydrated(true)
  }, [mapId])

  let maxX = 0
  let maxY = 0
  Object.keys(mapTiles).forEach((key) => {
    const [x, y] = key.split(",").map(Number)
    if (x > maxX) maxX = x
    if (y > maxY) maxY = y
  })

  // Don't render the map until we've applied the stored transform,
  // preventing a visible flash of the default position
  if (!hydrated) return null

  return (
    <div
      id='Map'
      className={style.map}
    >
      <TransformWrapper
        ref={transformRef}
        initialScale={savedTransform.scale}
        initialPositionX={savedTransform.positionX}
        initialPositionY={savedTransform.positionY}
        onTransform={({ state }) => {
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
        wheel={{
          step: 0.005, // faster zoom
        }}
        smooth={true}
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
  )
}
