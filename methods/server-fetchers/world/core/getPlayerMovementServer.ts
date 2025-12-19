// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetMethodFetcherServer.hbs
"use server"

import { arrayToObjectKey } from "@/methods/functions/util/converters"
import { getPlayerMovement } from "@/db/postgresMainDatabase/schemas/world/playerMovement"
import type { TPlayerMovement } from "@/db/postgresMainDatabase/schemas/world/playerMovement"
import type { TPlayerMovementParams } from "@/db/postgresMainDatabase/schemas/world/playerMovement" 
import type { TPlayerMovementRecordByXY } from "@/db/postgresMainDatabase/schemas/world/playerMovement"

// eslint-disable-next-line @typescript-eslint/no-explicit-any
let cachedData: any = null
const CACHE_TTL = 3_000
let lastUpdated = 0

export async function getPlayerMovementServer( params: TPlayerMovementParams): Promise<{
  raw: TPlayerMovement[]
  byKey: TPlayerMovementRecordByXY
  apiPath: string
  atomName: string
}> {
  if (cachedData && Date.now() - lastUpdated < CACHE_TTL) {
    return cachedData
  }
  
  const getPlayerMovementData = await getPlayerMovement(params)

  const data = getPlayerMovementData ? (arrayToObjectKey(["x", "y"], getPlayerMovementData) as TPlayerMovementRecordByXY) : {}

  const result = { raw: getPlayerMovementData, byKey: data, apiPath: `/api/world/rpc/get-player-movement/${params.playerId}`, atomName: `playerMovementAtom`  }

  cachedData = result
  lastUpdated = Date.now()

  return result
}

