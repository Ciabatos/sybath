// GENERATED CODE - SHOULD BE EDITED MANUALLY TO END CONFIGURATION - actionGetMethodAction.hbs
'use server'

import { auth } from '@/auth'
import { TPlayerMovementParams, playerMovement } from '@/db/postgresMainDatabase/schemas/world/playerMovement'
import { pathFromPointToPoint } from '@/methods/functions/map/pathFromPointToPoint'
import { getJoinedMap } from '@/methods/server-fetchers/world/composite/getJoinedMap'

type TPlayerMovementActionParams = {
  mapId: number
  startX: number
  startY: number
  endX: number
  endY: number
}

export async function playerMovementAction(params: TPlayerMovementActionParams) {
  const session = await auth()
  const playerId = session?.user?.playerId
  const joinedMap = await getJoinedMap(params.mapId)

  if (!playerId || isNaN(playerId)) {
    return
  }

  if (!joinedMap) {
    return
  }

  const path = pathFromPointToPoint({
    startX: params.startX,
    startY: params.startY,
    endX: params.endX,
    endY: params.endY,
    mapTiles: joinedMap.joinedMap,
  })

  const data: TPlayerMovementParams = {
    playerId: playerId,
    path: path,
  }

  try {
    const result = await playerMovement(data)
    return result
  } catch (error) {
    console.error('Error playerMovementAction :', error)
    return 'Failed to playerMovementAction'
  }
}
