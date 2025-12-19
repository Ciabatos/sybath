// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetMethodFetcherServer.hbs
"use server"

import { arrayToObjectKey } from "@/methods/functions/util/converters"
import { getPlayerPosition } from "@/db/postgresMainDatabase/schemas/world/playerPosition"
import type { TPlayerPosition } from "@/db/postgresMainDatabase/schemas/world/playerPosition"
import type { TPlayerPositionParams } from "@/db/postgresMainDatabase/schemas/world/playerPosition" 
import type { TPlayerPositionRecordByXY } from "@/db/postgresMainDatabase/schemas/world/playerPosition"

// eslint-disable-next-line @typescript-eslint/no-explicit-any
let cachedData: any = null
const CACHE_TTL = 3_000
let lastUpdated = 0

export async function getPlayerPositionServer( params: TPlayerPositionParams): Promise<{
  raw: TPlayerPosition[]
  byKey: TPlayerPositionRecordByXY
  apiPath: string
  atomName: string
}> {
  if (cachedData && Date.now() - lastUpdated < CACHE_TTL) {
    return cachedData
  }
  
  const getPlayerPositionData = await getPlayerPosition(params)

  const data = getPlayerPositionData ? (arrayToObjectKey(["x", "y"], getPlayerPositionData) as TPlayerPositionRecordByXY) : {}

  const result = { raw: getPlayerPositionData, byKey: data, apiPath: `/api/world/rpc/get-player-position/${params.mapId}/${params.playerId}`, atomName: `playerPositionAtom`  }

  cachedData = result
  lastUpdated = Date.now()

  return result
}

