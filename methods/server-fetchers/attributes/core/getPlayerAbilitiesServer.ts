// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetMethodFetcherServer.hbs
"use server"

import { arrayToObjectKey } from "@/methods/functions/util/converters"
import { getPlayerAbilities } from "@/db/postgresMainDatabase/schemas/attributes/playerAbilities"
import type { TPlayerAbilities } from "@/db/postgresMainDatabase/schemas/attributes/playerAbilities"
import type { TPlayerAbilitiesParams } from "@/db/postgresMainDatabase/schemas/attributes/playerAbilities"
import type { TPlayerAbilitiesRecordByAbilityId } from "@/db/postgresMainDatabase/schemas/attributes/playerAbilities"

export async function getPlayerAbilitiesServer(params: TPlayerAbilitiesParams): Promise<{
  raw: TPlayerAbilities[]
  byKey: TPlayerAbilitiesRecordByAbilityId
  apiPath: string
  atomName: string
}> {
  const getPlayerAbilitiesData = await getPlayerAbilities(params)

  const data = getPlayerAbilitiesData
    ? (arrayToObjectKey(["abilityId"], getPlayerAbilitiesData) as TPlayerAbilitiesRecordByAbilityId)
    : {}

  return {
    raw: getPlayerAbilitiesData,
    byKey: data,
    apiPath: `/api/attributes/rpc/get-player-abilities/${params.playerId}`,
    atomName: `playerAbilitiesAtom`,
  }
}
