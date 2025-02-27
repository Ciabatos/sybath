import { TjoinedMapTile } from "@/methods/functions/joinMapTilesServer"

 export function calculateRouteFromPiontToPoint( startX, startY, endX, endY, mapTiles, objectProperties ) {
  const visitedNodesInOrder = []





   

   
 }








function sortByDistance(unvisitedTiles: Record<string, TjoinedMapTile>, finishTile: Record<string, TjoinedMapTile>, w: number) {

let entries = Object.entries(unvisitedTiles);

  entries.sort((nodeA, nodeB) => {
    
    const eucalidean1 = Math.sqrt(Math.abs(finishNode.row - nodeA.row) * Math.abs(finishNode.row - nodeA.row) + Math.abs(finishNode.col - nodeA.col) * Math.abs(finishNode.col - nodeA.col))
    const eucalidean2 = Math.sqrt(Math.abs(finishNode.row - nodeB.row) * Math.abs(finishNode.row - nodeB.row) + Math.abs(finishNode.col - nodeB.col) * Math.abs(finishNode.col - nodeB.col))
    const chebyschev1 = Math.max(Math.abs(finishNode.row - nodeA.row) + Math.abs(finishNode.col - nodeA.col))
    const chebyschev2 = Math.max(Math.abs(finishNode.row - nodeB.row) + Math.abs(finishNode.col - nodeB.col))

    // Calculate the combined heuristic for nodeA and nodeB
    const combinedHeuristicA = w * eucalidean1 + (1 - w) * chebyschev1
    const combinedHeuristicB = w * eucalidean2 + (1 - w) * chebyschev2

    const distanceToA = nodeA.distance + combinedHeuristicA + nodeA.MovmentCost // Zmiana + nodeA.ArmyMapGuardArea
    const distanceToB = nodeB.distance + combinedHeuristicB + nodeB.MovmentCost  // Zmiana + nodeB.ArmyMapGuardArea

    return distanceToA - distanceToB
  })
  
}
