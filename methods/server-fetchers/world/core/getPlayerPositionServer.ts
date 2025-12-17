// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetMethodFetcherServer.hbs
"use server"

import { arrayToObjectKey } from "@/methods/functions/util/converters"
import { getPlayerPosition } from "@/db/postgresMainDatabase/schemas/world/playerPosition"
import type { TPlayerPosition } from "@/db/postgresMainDatabase/schemas/world/playerPosition"
import type { TPlayerPositionParams } from "@/db/postgresMainDatabase/schemas/world/playerPosition"
import type { TPlayerPositionRecordByXY } from "@/db/postgresMainDatabase/schemas/world/playerPosition"

export async function getPlayerPositionServer(params: TPlayerPositionParams): Promise<{
  raw: TPlayerPosition[]
  byKey: TPlayerPositionRecordByXY
  apiPath: string
  atomName: string
}> {
  const getPlayerPositionData = await getPlayerPosition(params)

  const data = getPlayerPositionData
    ? (arrayToObjectKey(["x", "y"], getPlayerPositionData) as TPlayerPositionRecordByXY)
    : {}

  return {
    raw: getPlayerPositionData,
    byKey: data,
    apiPath: `/api/world/rpc/get-player-position/${params.mapId}/${params.playerId}`,
    atomName: `playerPositionAtom`,
  }
}
