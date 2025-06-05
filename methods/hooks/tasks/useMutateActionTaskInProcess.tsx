"use client"
import { TActionTaskInProcess } from "@/app/api/map-tiles/action-task-in-process/route"
import { TMovementPath } from "@/methods/hooks/mapTiles/useMapTilesPath"
import { actionTaskInProcessAtom } from "@/store/atoms"
import { useSetAtom } from "jotai"
import useSWR from "swr"

export function useMutateActionTaskInProcess() {
  const { mutate } = useSWR("/api/map-tiles/action-task-in-process")
  const setActionTaskInProcess = useSetAtom(actionTaskInProcessAtom)

  function mutateActionTaskInProcess(movementPath: TMovementPath[]) {
    const optimisticData: TActionTaskInProcess = {
      movementInProcess: movementPath.map((tile) => ({
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
