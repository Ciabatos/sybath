"use client"

import { astar, Graph } from "@/methods/functions/astar"
import { joinedMapTilesAtom } from "@/store/atoms"
import { useAtomValue } from "jotai"

interface GridNode {
  x: number // The X coordinate of the node
  y: number // The Y coordinate of the node
  weight: number // The weight of the node (terrain type or cost)
  f: number // The F cost (used in A* for pathfinding: f = g + h)
  g: number // The G cost (distance from the start node)
  h: number // The H cost (heuristic estimation to the end node)
  parent: GridNode | null // Reference to the parent node (used for tracing the path)
  closed: boolean // Whether the node has been closed in the pathfinding process
  visited: boolean // Whether the node has been visited in the search process
}

export interface TMovmentPath {
  tileCost: number
  id?: number | undefined
  map_id?: number | undefined
  x?: number | undefined
  y?: number | undefined
  terrain_type_id?: number | undefined
}

export function useMapTilesPath() {
  const mapTiles = useAtomValue(joinedMapTilesAtom)

  function runAStar(startX: number, startY: number, endX: number, endY: number, objectProperties: unknown): TMovmentPath[] {
    if (!startX || !startY || !endX || !endY) {
      return []
    }

    const mapTilesArray = Object.values(mapTiles)

    const gridSize = Math.sqrt(mapTilesArray.length) + 1
    const grid = Array.from({ length: gridSize }, () => Array(gridSize).fill(0))

    mapTilesArray.forEach((tile) => {
      grid[tile.x][tile.y] = tile.terrain_move_cost ?? 0 + (objectProperties as number)
      // koszt ruchu tiles
      // 0 - wall
      // im wieksze tym wiekszy koszt
    })

    const graphWithWeight = new Graph(grid, { diagonal: true })

    const startWithWeight = graphWithWeight.grid[startX][startY]
    const endWithWeight = graphWithWeight.grid[endX][endY]

    const resultWithWeight: GridNode[] = astar.search(graphWithWeight, startWithWeight, endWithWeight)

    const filteredMapTiles = resultWithWeight.map((node) => {
      const tile = mapTilesArray.find((t) => t.x === node.x && t.y === node.y)

      return {
        ...tile,
        tileCost: node.weight,
      }
    })

    return filteredMapTiles
  }

  return { runAStar }
}
