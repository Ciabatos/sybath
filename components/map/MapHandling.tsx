"use client"

import Map from "@/components/map/Map"
import { useMapHandlingData } from "@/methods/hooks/world/composite/useMapHandlingData"

export default function MapHandling() {
  const { combinedMap } = useMapHandlingData()

  return (
    <>
      {combinedMap.map(({ key, ...combinedMapProps }) => (
        <Map
          key={key}
          {...combinedMapProps}
        />
      ))}
    </>
  )
}
