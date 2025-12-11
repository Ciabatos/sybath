type TCalculateAreaFromPointParams = {
  startX: number
  startY: number
  range: number
}

export type TCalculateAreaFromPoint = {
  x: number
  y: number
}

export function calculateAreaFromPoint(params: TCalculateAreaFromPointParams): TCalculateAreaFromPoint[] {
  if (!params) {
    return []
  }

  const AreaXY: { x: number; y: number }[] = []

  for (let x = params.startX - params.range; x <= params.startX + params.range; x++) {
    for (let y = params.startY - params.range; y <= params.startY + params.range; y++) {
      const dist = Math.abs(params.startX - x) + Math.abs(params.startY - y)
      if (dist <= params.range || dist <= params.range * 2) {
        AreaXY.push({ x, y })
      }
    }
  }

  return AreaXY
}
