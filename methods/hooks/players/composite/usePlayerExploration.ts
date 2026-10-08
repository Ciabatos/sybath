"use client"

import { doMapTileExplorationAction } from "@/methods/actions/world/doMapTileExplorationAction"
import { usePlayerAbilities } from "@/methods/hooks/attributes/composite/usePlayerAbilities"
import { usePlayerId } from "@/methods/hooks/players/composite/usePlayerId"
import { usePlayerMovement } from "@/methods/hooks/players/composite/usePlayerMovement"
import { useMapId } from "@/methods/hooks/world/composite/useMapId"
import { useMapTileActions } from "@/methods/hooks/world/composite/useMapTileActions"
import { useFetchPlayerPosition, usePlayerPositionState } from "@/methods/hooks/world/core/useFetchPlayerPosition"
import { useMutateKnownMapTilesResourcesOnTile } from "@/methods/hooks/world/core/useMutateKnownMapTilesResourcesOnTile"
import { isExploringAtom } from "@/store/atoms"
import { useAtom } from "jotai"
import { toast } from "sonner"

/** Indeks zdolności odpowiedzialnej za eksplorację w `playerAbilities`. */
const EXPLORATION_ABILITY_INDEX = 2

export function usePlayerExploration() {
  const { playerId } = usePlayerId()
  const { mapId } = useMapId()
  const { clickedMapTile } = useMapTileActions()
  const { selectPlayerPathToClickedTile, selectPlayerPathAndMovePlayerToClickedTile, closeMovementPanel } =
    usePlayerMovement()
  const { playerAbilities } = usePlayerAbilities()
  useFetchPlayerPosition({ mapId, playerId })
  const playerPosition = usePlayerPositionState()

  // Atom, nie useState — ten hook wołany jest z kilku komponentów.
  // Z useState każde wywołanie miałoby własną, niezależną kopię flagi.
  const [isExploring, setIsExploring] = useAtom(isExploringAtom)

  const { mutateKnownMapTilesResourcesOnTile } = useMutateKnownMapTilesResourcesOnTile({
    mapId,
    mapTileX: clickedMapTile?.mapTiles.x ?? 0,
    mapTileY: clickedMapTile?.mapTiles.y ?? 0,
    playerId,
  })

  function hasExplorationAbility(): boolean {
    if (!playerAbilities[EXPLORATION_ABILITY_INDEX]?.value) {
      toast.error("Player does not have exploration ability")
      return false
    }
    return true
  }

  /** Czy gracz stoi już na tym kafelku. Klucz budowany tak samo jak w useFetchPlayerPosition. */
  function isStandingOnTile(): boolean {
    if (!clickedMapTile) return false
    return Boolean(playerPosition[`${clickedMapTile.mapTiles.x},${clickedMapTile.mapTiles.y}`])
  }

  async function exploreClickedTilePlan(): Promise<boolean> {
    if (!clickedMapTile) {
      toast.error("No tile selected")
      return false
    }

    try {
      if (!hasExplorationAbility()) return false

      if (!isStandingOnTile()) {
        // Funkcja zwraca teraz prawdziwe `false`, gdy nie da się zaplanować ruchu.
        const didPlanMove = await selectPlayerPathToClickedTile()

        if (!didPlanMove) return false
      }

      setIsExploring(true)
      return true
    } catch (error) {
      console.error("Error exploring tile:", error)
      toast.error("Could not plan the exploration")
      return false
    }
  }

  async function exploreClickedTileConfirm(): Promise<boolean> {
    if (!clickedMapTile) {
      toast.error("No tile selected")
      return false
    }

    try {
      if (!hasExplorationAbility()) return false

      if (!isStandingOnTile()) {
        const didMove = await selectPlayerPathAndMovePlayerToClickedTile()

        if (!didMove) return false
      }

      const result = await doMapTileExplorationAction({
        playerId,
        mapId: mapId,
        targetTileX: clickedMapTile.mapTiles.x,
        targetTileY: clickedMapTile.mapTiles.y,
      })

      if (!result.status) {
        toast.error(result.message)
        return false
      }

      mutateKnownMapTilesResourcesOnTile()
      setIsExploring(false)

      toast.success(`You are exploring destination tile`)
      return true
    } catch (error) {
      console.error("Error exploring tile:", error)
      toast.error("Could not explore the tile")
      return false
    }
  }

  function closeExplorationPanel() {
    closeMovementPanel()
    setIsExploring(false)
  }

  return { isExploring, exploreClickedTilePlan, exploreClickedTileConfirm, closeExplorationPanel }
}
