import { astar, Graph } from "@/methods/functions/astar"
import { TJoinedMapTile, TJoinedMapTileByCoordinates } from "@/methods/functions/joinMapTiles"

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

export interface TMovementPath extends TJoinedMapTile {
  totalMovementCost: number
}
export function pathFromPointToPoint(startX: number, startY: number, endX: number, endY: number, objectProperties: unknown, mapTiles: TJoinedMapTileByCoordinates): TMovementPath[] {
  if (!startX || !startY || !endX || !endY) {
    return []
  }

  const mapTilesArray = Object.values(mapTiles)
  if (mapTilesArray.length === 0) return []

  const gridSize = Math.sqrt(mapTilesArray.length) + 1
  const grid = Array.from({ length: gridSize }, () => Array(gridSize).fill(0))

  mapTilesArray.forEach((tile) => {
    grid[tile.mapTile.x][tile.mapTile.y] = tile.moveCost ?? 0 + (objectProperties as number)
    // koszt ruchu tiles
    // 0 - wall
    // im wieksze tym wiekszy koszt
  })

  const graphWithWeight = new Graph(grid, { diagonal: true })

  const startWithWeight = graphWithWeight.grid[startX][startY]
  const endWithWeight = graphWithWeight.grid[endX][endY]

  const resultWithWeight: GridNode[] = astar.search(graphWithWeight, startWithWeight, endWithWeight)

  const startNode = { x: startX, y: startY, weight: 0.1 } as GridNode
  const fullPath = [startNode, ...resultWithWeight]

  const filteredMapTiles = fullPath.map((node) => {
    const tile = mapTilesArray.find((t) => t.mapTile.x === node.x && t.mapTile.y === node.y)
    if (!tile) {
      throw new Error(`Tile not found at coordinates (${node.x}, ${node.y})`)
    }
    return {
      ...tile,
      totalMovementCost: node.weight,
    }
  })

  return filteredMapTiles
}
