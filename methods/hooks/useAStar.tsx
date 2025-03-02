"use client"

import { astar, Graph } from "@/methods/functions/astar"
import { useAtomValue } from "jotai"
import { mapTilesAtom } from "@/store/atoms"

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

export function useAStar(startX: number, startY: number, endX: number, endY: number, objectProperties: unknown) {
  const mapTiles = useAtomValue(mapTilesAtom)

  const runAStar = () => {
    const gridSize = Math.sqrt(mapTiles.length) + 1
    const grid = Array.from({ length: gridSize }, () => Array(gridSize).fill(0))

    mapTiles.forEach((tile) => {
      grid[tile.y][tile.x] = tile.terrain_type_id + (objectProperties as number) // koszt ruchu tiles
    })

    const graphWithWeight = new Graph(grid, { diagonal: true })

    const startWithWeight = graphWithWeight.grid[startX][startY]
    const endWithWeight = graphWithWeight.grid[endX][endY]
    const resultWithWeight: GridNode[] = astar.search(graphWithWeight, startWithWeight, endWithWeight)

    const filteredMapTiles = resultWithWeight.map((node) => {
      const tile = mapTiles.find((t) => t.x === node.x && t.y === node.y)

      return {
        ...tile,
        tileCost: node.weight,
      }
    })

    return filteredMapTiles
  }

  return runAStar
}
