// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetTableByKeyServer.hbs
"use server"

import { arrayToObjectKey } from "@/methods/functions/util/converters"
import { getAttributesPlayerAbilitiesByKey } from "@/db/postgresMainDatabase/schemas/attributes/playerAbilities"
import { TAttributesPlayerAbilitiesParams } from "@/db/postgresMainDatabase/schemas/attributes/playerAbilities"
import type {
  TAttributesPlayerAbilities,
  TAttributesPlayerAbilitiesRecordByPlayerId,
} from "@/db/postgresMainDatabase/schemas/attributes/playerAbilities"

export async function getAttributesPlayerAbilitiesByKeyServer(params: TAttributesPlayerAbilitiesParams): Promise<{
  raw: TAttributesPlayerAbilities[]
  byKey: TAttributesPlayerAbilitiesRecordByPlayerId
  apiPath: string
}> {
  const getAttributesPlayerAbilitiesByKeyData = await getAttributesPlayerAbilitiesByKey(params)

  const data = getAttributesPlayerAbilitiesByKeyData
    ? (arrayToObjectKey(
        ["playerId"],
        getAttributesPlayerAbilitiesByKeyData,
      ) as TAttributesPlayerAbilitiesRecordByPlayerId)
    : {}

  return {
    raw: getAttributesPlayerAbilitiesByKeyData,
    byKey: data,
    apiPath: `/api/attributes/player-abilities/${params.playerId}`,
  }
}
