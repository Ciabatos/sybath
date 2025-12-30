// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetMethodFetcherServer.hbs
"use server"

import { arrayToObjectKey } from "@/methods/functions/util/converters"
import { getPlayerAbilities } from "@/db/postgresMainDatabase/schemas/attributes/playerAbilities"
import type { TPlayerAbilities } from "@/db/postgresMainDatabase/schemas/attributes/playerAbilities"
import type { TPlayerAbilitiesParams } from "@/db/postgresMainDatabase/schemas/attributes/playerAbilities"
import type { TPlayerAbilitiesRecordByAbilityId } from "@/db/postgresMainDatabase/schemas/attributes/playerAbilities"

// eslint-disable-next-line @typescript-eslint/no-explicit-any
let cachedData: any = null
const CACHE_TTL = 3_000
let lastUpdated = 0

export async function getPlayerAbilitiesServer(params: TPlayerAbilitiesParams): Promise<{
  raw: TPlayerAbilities[]
  byKey: TPlayerAbilitiesRecordByAbilityId
  apiPath: string
  atomName: string
}> {
  if (cachedData && Date.now() - lastUpdated < CACHE_TTL) {
    return cachedData
  }

  const getPlayerAbilitiesData = await getPlayerAbilities(params)

  const data = getPlayerAbilitiesData
    ? (arrayToObjectKey(["abilityId"], getPlayerAbilitiesData) as TPlayerAbilitiesRecordByAbilityId)
    : {}

  const result = {
    raw: getPlayerAbilitiesData,
    byKey: data,
    apiPath: `/api/attributes/rpc/get-player-abilities/${params.playerId}`,
    atomName: `playerAbilitiesAtom`,
  }

  cachedData = result
  lastUpdated = Date.now()

  return result
}
