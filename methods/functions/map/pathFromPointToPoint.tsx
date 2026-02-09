import { TCitiesCitiesRecordByMapTileXMapTileY } from "@/db/postgresMainDatabase/schemas/cities/cities"
import { TWorldLandscapeTypesRecordById } from "@/db/postgresMainDatabase/schemas/world/landscapeTypes"
import { TWorldMapTilesRecordByXY } from "@/db/postgresMainDatabase/schemas/world/mapTiles"
import { TPlayerMovement } from "@/db/postgresMainDatabase/schemas/world/playerMovement"
import { TWorldTerrainTypesRecordById } from "@/db/postgresMainDatabase/schemas/world/terrainTypes"
import { astar, Graph } from "@/methods/functions/map/astar.cjs"

type GridNode = {
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

type TPathFromPointToPointParams = {
  startX: number
  startY: number
  endX: number
  endY: number
  mapTiles: TWorldMapTilesRecordByXY
  terrainTypes: TWorldTerrainTypesRecordById
  landscapeTypes: TWorldLandscapeTypesRecordById
  cities: TCitiesCitiesRecordByMapTileXMapTileY
}

export function pathFromPointToPoint(params: TPathFromPointToPointParams): TPlayerMovement[] {
  if (!params) {
    return []
  }

  const mapTilesArray = Object.values(params.mapTiles)
  if (mapTilesArray.length === 0) return []

  const gridSize = Math.sqrt(mapTilesArray.length) + 1
  const grid = Array.from({ length: gridSize }, () => Array(gridSize).fill(0))

  mapTilesArray.forEach((tile) => {
    let cost = 0

    if (params.terrainTypes[tile.terrainTypeId]) {
      cost += params.terrainTypes[tile.terrainTypeId].moveCost
    }

    if (tile.landscapeTypeId !== undefined && params.landscapeTypes[tile.landscapeTypeId]) {
      cost += params.landscapeTypes[tile.landscapeTypeId].moveCost
    }

    if (params.cities[`${tile.x},${tile.y}`]) {
      cost += params.cities[`${tile.x},${tile.y}`].moveCost
    }

    grid[tile.x][tile.y] = cost

    // koszt ruchu tiles
    // 0 - wall
    // im wieksze tym wiekszy koszt
  })

  const graphWithWeight = new Graph(grid, { diagonal: true })

  const startWithWeight = graphWithWeight.grid[params.startX][params.startY]
  const endWithWeight = graphWithWeight.grid[params.endX][params.endY]

  const resultWithWeight: GridNode[] = astar.search(graphWithWeight, startWithWeight, endWithWeight)

  const startNode = { x: params.startX, y: params.startY, weight: 0.001 } as GridNode
  const fullPath = [startNode, ...resultWithWeight]

  const filteredMapTiles = fullPath.map((node) => {
    const tile = mapTilesArray.find((tile) => tile.x === node.x && tile.y === node.y)
    return {
      moveCost: grid[node.x][node.y],
      x: node.x,
      y: node.y,
      totalMoveCost: node.weight,
    }
  })

  return filteredMapTiles
}
