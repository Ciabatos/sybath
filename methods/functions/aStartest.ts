
export function Astar(grid, startNode, finishNode, ActionPoints) {
  const visitedNodesInOrder = []
  startNode.distance = 0
  startNode.MovmentCost = 0

  // Pobieramy wszystkie węzły z siatki, z których tworzymy obiekt
  const unvisitedNodes = getAllNodesAsObject(grid)

  // Iterujemy po wszystkich niezvisitedNodes (obiekt), dopóki nie odwiedzimy wszystkich lub nie napotkamy nieosiągalnego celu
  while (Object.keys(unvisitedNodes).length > 0) {
    // Sortujemy węzły na podstawie odległości (przybliżenie A* z uwzględnieniem heurystyki)
    const sortedNodes = Object.values(unvisitedNodes).sort((a, b) => a.distance - b.distance)
    const closestNode = sortedNodes[0]

    // Jeśli napotkamy węzeł, który jest ścianą, pomijamy go
    if (closestNode.isWall) {
      // Usuwamy węzeł z unvisitedNodes
      delete unvisitedNodes[`${closestNode.x},${closestNode.y}`]
      continue
    }

    // Jeśli najbliższy węzeł ma odległość równą nieskończoności, oznacza to, że nie możemy osiągnąć celu
    if (closestNode.distance === Infinity) {
      return visitedNodesInOrder
    }

    // Zmniejszamy dostępne punkty akcji
    ActionPoints -= closestNode.MovmentCost

    // Oznaczamy węzeł jako odwiedzony
    closestNode.isVisited = true

    // Jeśli zabraknie punktów akcji, przerywamy i nie kontynuujemy węzła
    if (ActionPoints < 0) {
      closestNode.previousNode = null
      return visitedNodesInOrder
    } else {
      visitedNodesInOrder.push(closestNode)
    }

    // Jeśli punkty akcji spadły do zera, kończymy, bo nie możemy wykonać żadnych dalszych ruchów
    if (ActionPoints === 0) {
      return visitedNodesInOrder
    }

    // Jeśli najbliższy węzeł to węzeł końcowy, zwracamy listę odwiedzonych węzłów
    if (closestNode === finishNode) {
      return visitedNodesInOrder
    }

    // Aktualizujemy odległości sąsiadów najbliższego węzła
    updateUnvisitedNeighbors(closestNode, grid, finishNode)

    // Usuwamy najbliższy węzeł z unvisitedNodes
    delete unvisitedNodes[`${closestNode.x},${closestNode.y}`]
  }
}

// Funkcja do pobierania wszystkich węzłów jako obiekt
function getAllNodesAsObject(grid) {
  const nodes = {}
  grid.forEach(row => {
    row.forEach(node => {
      const key = `${node.x},${node.y}`
      nodes[key] = node
    })
  })
  return nodes
}










const tiles = {
  "0,0": { x: 0, y: 0, value: "tile1" },
  "0,1": { x: 0, y: 1, value: "tile2" },
  "1,0": { x: 1, y: 0, value: "tile3" },
  "1,1": { x: 1, y: 1, value: "tile4" },
  // Add more tiles here...
};

const findNeighbors = (x, y, tiles) => {
  const neighbors = [];
  
  // Define the 8 possible neighbors (including diagonals)
  const directions = [
    [-1, -1], [0, -1], [1, -1],
    [-1,  0],          [1,  0],
    [-1,  1], [0,  1], [1,  1]
  ];
  
  for (const [dx, dy] of directions) {
    const neighborKey = `${x + dx},${y + dy}`; // Generate the key for the neighbor
    if (tiles[neighborKey]) {
      neighbors.push(tiles[neighborKey]);
    }
  }

  return neighbors;
};

console.log(findNeighbors(0, 0, tiles));










