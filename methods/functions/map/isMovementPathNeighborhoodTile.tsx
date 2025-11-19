export function isMovementPathNeighborhoodTile(xyArrayOfArrays: { x: number; y: number }[]): boolean {
  for (let i = 0; i < xyArrayOfArrays.length - 1; i++) {
    const { x: x1, y: y1 } = xyArrayOfArrays[i]
    const { x: x2, y: y2 } = xyArrayOfArrays[i + 1]

    const dx = Math.abs(x2 - x1)
    const dy = Math.abs(y2 - y1)

    // Zakładamy, że ruch może być w 8 kierunkach (w tym po skosie)
    if (dx > 1 || dy > 1) {
      return false
    }
  }
  return true
}
