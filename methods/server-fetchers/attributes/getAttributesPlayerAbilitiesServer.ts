// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetTableServer.hbs
"use server"

import { arrayToObjectKey } from "@/methods/functions/util/converters"
import { getAttributesPlayerAbilities } from "@/db/postgresMainDatabase/schemas/attributes/playerAbilities"
import type { TAttributesPlayerAbilities, TAttributesPlayerAbilitiesRecordByPlayerId } from "@/db/postgresMainDatabase/schemas/attributes/playerAbilities"

export async function getAttributesPlayerAbilitiesServer(): Promise<{
  raw: TAttributesPlayerAbilities[]
  byKey: TAttributesPlayerAbilitiesRecordByPlayerId
  apiPath: string
}> {
  const getAttributesPlayerAbilitiesData = await getAttributesPlayerAbilities()

  const data = getAttributesPlayerAbilitiesData ? (arrayToObjectKey(["playerId"], getAttributesPlayerAbilitiesData) as TAttributesPlayerAbilitiesRecordByPlayerId) : {}

  return { raw: getAttributesPlayerAbilitiesData, byKey: data, apiPath: `/api/attributes/player-abilities` }
}
