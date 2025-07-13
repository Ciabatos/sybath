"use client"
import { TActionTaskInProcess } from "@/app/api/map-tiles/action-task-in-process/route"
import { actionTaskInProcessAtom, joinedMapTilesAtom } from "@/store/atoms"
import { useAtomValue, useSetAtom } from "jotai"
import useSWR from "swr"

export function useMutateActionTaskInProcess() {
  const { mutate } = useSWR("/api/map-tiles/action-task-in-process")
  const setActionTaskInProcess = useSetAtom(actionTaskInProcessAtom)
  const joinedMapTiles = useAtomValue(joinedMapTilesAtom)

  function mutateActionTaskInProcess(mapTilesMovementPathSet?: Set<string>) {
    const movementPathTiles = Array.from(mapTilesMovementPathSet ?? []).map((key) => joinedMapTiles[key])

    const optimisticData: TActionTaskInProcess = {
      movementInProcess: movementPathTiles.map((tile) => ({
        scheduled_at: null,
        method_parameters: {
          x: tile.mapTile.x,
          y: tile.mapTile.y,
          playerId: 0,
        },
      })),
    }

    setActionTaskInProcess(optimisticData)
    mutate(undefined, {
      optimisticData,
      rollbackOnError: true,
      revalidate: false,
      populateCache: true,
    })
  }

  return { mutateActionTaskInProcess }
}
