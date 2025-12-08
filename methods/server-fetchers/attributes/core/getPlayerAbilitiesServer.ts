// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetMethodFetcherServer.hbs
"use server"

import { arrayToObjectKey } from "@/methods/functions/util/converters"
import { getPlayerAbilities } from "@/db/postgresMainDatabase/schemas/attributes/getPlayerAbilities"
import type { TGetPlayerAbilities } from "@/db/postgresMainDatabase/schemas/attributes/getPlayerAbilities"
import type { TGetPlayerAbilitiesParams } from "@/db/postgresMainDatabase/schemas/attributes/getPlayerAbilities"
import type { TGetPlayerAbilitiesRecordByAbilityId } from "@/db/postgresMainDatabase/schemas/attributes/getPlayerAbilities"

export async function getPlayerAbilitiesServer(params: TGetPlayerAbilitiesParams): Promise<{
  raw: TGetPlayerAbilities[]
  byKey: TGetPlayerAbilitiesRecordByAbilityId
  apiPath: string
}> {
  const getPlayerAbilitiesData = await getPlayerAbilities(params)

  const data = getPlayerAbilitiesData ? (arrayToObjectKey(["abilityId"], getPlayerAbilitiesData) as TGetPlayerAbilitiesRecordByAbilityId) : {}

  return { raw: getPlayerAbilitiesData, byKey: data, apiPath: `/api/attributes/rpc/get-player-abilities/${params.playerId}` }
}
