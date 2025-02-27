export function Astar(grid, startNode, finishNode, ActionPoints) {
  const visitedNodesInOrder = [];
  startNode.distance = 0;
  startNode.MovmentCost = 0;

  const openSet = new PriorityQueue();
  const w = 0.5; // Weight for combined heuristic
  const startPriority = calculatePriority(startNode, finishNode, w);
  openSet.enqueue(startNode, startPriority);

  while (!openSet.isEmpty()) {
    const closestNode = openSet.dequeue();

    if (closestNode.isWall || closestNode.isVisited) continue;

    // Deduct ActionPoints for moving to this node
    const movementCost = closestNode.MovmentCost;
    if (ActionPoints - movementCost < 0) {
      closestNode.previousNode = null;
      return visitedNodesInOrder;
    }
    ActionPoints -= movementCost;

    closestNode.isVisited = true;
    visitedNodesInOrder.push(closestNode);

    if (ActionPoints === 0 || closestNode === finishNode) {
      return visitedNodesInOrder;
    }

    const unvisitedNeighbors = getUnvisitedNeighbors(closestNode, grid);
    for (const neighbor of unvisitedNeighbors) {
      if (neighbor.isVisited) continue;

      // Update neighbor's distance and previous node
      if (neighbor === finishNode) {
        neighbor.distance = closestNode.distance - 1;
      } else {
        neighbor.distance = closestNode.distance + 1;
      }
      neighbor.previousNode = closestNode;

      const priority = calculatePriority(neighbor, finishNode, w);
      openSet.enqueue(neighbor, priority);
    }
  }

  return visitedNodesInOrder;
}

// Helper function to calculate priority using combined heuristic
function calculatePriority(node, finishNode, w) {
  const dx = Math.abs(finishNode.row - node.row);
  const dy = Math.abs(finishNode.col - node.col);
  const euclidean = Math.sqrt(dx * dx + dy * dy);
  const chebyshev = Math.max(dx, dy);
  const combinedHeuristic = w * euclidean + (1 - w) * chebyshev;
  return node.distance + combinedHeuristic + node.MovmentCost;
}

// Priority Queue implementation using min-heap
class PriorityQueue {
  constructor() {
    this.heap = [];
  }

  enqueue(node, priority) {
    this.heap.push({ node, priority });
    this.bubbleUp();
  }

  bubbleUp() {
    let index = this.heap.length - 1;
    while (index > 0) {
      const parentIndex = Math.floor((index - 1) / 2);
      if (this.heap[parentIndex].priority <= this.heap[index].priority) break;
      [this.heap[parentIndex], this.heap[index]] = [this.heap[index], this.heap[parentIndex]];
      index = parentIndex;
    }
  }

  dequeue() {
    const min = this.heap[0];
    const end = this.heap.pop();
    if (this.heap.length > 0) {
      this.heap[0] = end;
      this.sinkDown();
    }
    return min.node;
  }

  sinkDown() {
    let index = 0;
    const length = this.heap.length;
    while (true) {
      const leftChildIdx = 2 * index + 1;
      const rightChildIdx = 2 * index + 2;
      let swapIdx = null;

      if (leftChildIdx < length && this.heap[leftChildIdx].priority < this.heap[index].priority) {
        swapIdx = leftChildIdx;
      }
      if (rightChildIdx < length) {
        if ((swapIdx === null && this.heap[rightChildIdx].priority < this.heap[index].priority) ||
           (swapIdx !== null && this.heap[rightChildIdx].priority < this.heap[leftChildIdx].priority)) {
          swapIdx = rightChildIdx;
        }
      }

      if (swapIdx === null) break;
      [this.heap[index], this.heap[swapIdx]] = [this.heap[swapIdx], this.heap[index]];
      index = swapIdx;
    }
  }

  isEmpty() {
    return this.heap.length === 0;
  }
}

// The rest of the helper functions (getUnvisitedNeighbors, getNodesInShortestPathOrder) remain unchanged
