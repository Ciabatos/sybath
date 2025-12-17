"use client"

import Map from "@/components/map/Map"
import { useRefreshJoinedMap } from "@/methods/hooks/world/composite/useRefreshJoinedMap"

export default function MapHandling() {
  const { refreshedJoinedMap } = useRefreshJoinedMap()

  return (
    <>
      {Object.entries(refreshedJoinedMap).map(([key, tile]) => (
        <Map
          key={key}
          tile={tile}
        />
      ))}
    </>
  )
}
