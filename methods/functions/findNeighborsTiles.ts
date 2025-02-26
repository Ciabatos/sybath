import type { TjoinedMapTile } from "@/methods/functions/joinMapTilesServer"

export function findNeighborsTiles(masterX: number, masterY: number, mapTiles: Record<string, TjoinedMapTile>) {
  const neighborsTiles = []

  // prettier-ignore
  const directions = [
	  [-1, -1], [0, -1], [1, -1],
	  [-1,  0],          [1,  0],
	  [-1,  1], [0,  1], [1,  1]
	]

  for (const [neighborX, neighborY] of directions) {
    const neighborKey = `${masterX + neighborX},${masterY + neighborY}`
    if (mapTiles[neighborKey]) {
      neighborsTiles.push(mapTiles[neighborKey])
    }
  }

  return neighborsTiles
}
