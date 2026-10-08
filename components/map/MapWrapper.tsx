"use client"

import MapHandling from "@/components/map/MapHandling"
import MapLayersPanel from "@/components/map/MapLayersPanel"
import RegionLayerProvince from "@/components/map/layers/mapOverlay/RegionLayerProvince"
import { useMapHandling } from "@/methods/hooks/world/composite/useMapHandling"
import { useCallback, useEffect, useRef, useState } from "react"
import { TransformComponent, TransformWrapper } from "react-zoom-pan-pinch"
import style from "./styles/MapWrapper.module.css"

const DEFAULT_TRANSFORM = { scale: 1, positionX: 0, positionY: 0 }

/** Co ile ms zapisujemy pozycję do localStorage. */
const SAVE_INTERVAL_MS = 400

export default function MapWrapper() {
  const { mapId } = useMapHandling()

  // Pozycja jest zapisywana w onTransform, czyli co klatkę podczas
  // przeciągania. localStorage.setItem jest synchroniczny, więc bez throttlingu
  // blokował główny wątek na każdej klatce.
  const pendingTransform = useRef(DEFAULT_TRANSFORM)
  const lastSave = useRef(0)

  // Zawsze startujemy od wartości domyślnych — zgodne z renderem serwera.
  const [savedTransform, setSavedTransform] = useState(DEFAULT_TRANSFORM)
  const [hydrated, setHydrated] = useState(false)

  // Po zamontowaniu odczytujemy localStorage i aktualizujemy w razie potrzeby.
  useEffect(() => {
    const stored = localStorage.getItem(`Map${mapId}ZoomState`)

    if (stored) {
      try {
        setSavedTransform(JSON.parse(stored))
      } catch {
        // ignoruj uszkodzone dane
      }
    }

    setHydrated(true)
  }, [mapId])

  // Ostatni zapis przy odjeździe, żeby nie stracić pozycji przy zamknięciu.
  useEffect(() => {
    function flush() {
      window.removeEventListener("beforeunload", flush)
      localStorage.setItem(`Map${mapId}ZoomState`, JSON.stringify(pendingTransform.current))
    }

    window.addEventListener("beforeunload", flush)
    return () => {
      flush()
      window.removeEventListener("beforeunload", flush)
    }
  }, [mapId])

  const handleTransform = useCallback(
    ({ state }: { state: { scale: number; positionX: number; positionY: number } }) => {
      pendingTransform.current = {
        scale: state.scale,
        positionX: state.positionX,
        positionY: state.positionY,
      }

      const now = Date.now()
      if (now - lastSave.current < SAVE_INTERVAL_MS) return

      lastSave.current = now
      localStorage.setItem(`Map${mapId}ZoomState`, JSON.stringify(pendingTransform.current))
    },
    [mapId],
  )

  // Nie renderujemy mapy, dopóki nie zastosowaliśmy zapisanej pozycji —
  // inaczej widać byłoby skok do domyślnego położenia.
  if (!hydrated) return null

  return (
    <div
      id='Map'
      className={style.map}
    >
      <TransformWrapper
        initialScale={savedTransform.scale}
        initialPositionX={savedTransform.positionX}
        initialPositionY={savedTransform.positionY}
        onTransform={handleTransform}
        minScale={0.4}
        maxScale={2.5}
        wheel={{
          step: 0.005,
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
            {/* Obrys regionów to część bazy — zawsze rysowana, nie do przełączania. */}
            <RegionLayerProvince />
          </div>
        </TransformComponent>
      </TransformWrapper>

      {/*
        Nakładka z warstwami stoi OBOK TransformWrapper, nie wewnątrz — inaczej
        skalowałaby się i przesuwała razem z mapą.
      */}
      <MapLayersPanel />
    </div>
  )
}