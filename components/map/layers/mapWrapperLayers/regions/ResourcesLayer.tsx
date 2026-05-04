"use client"

import { useResourcesLayer } from "@/methods/hooks/world/composite/useResourcesLayer"

export default function ResourcesLayer() {
  const { knownMapTilesResourcesOnMap } = useResourcesLayer()

  return (
    <>
      {Object.entries(knownMapTilesResourcesOnMap).map(([id, resources]) => {
        return <div> </div>
      })}
    </>
  )
}
