// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetMethodFetcherServer.hbs
"use server"

import { arrayToObjectKey } from "@/methods/functions/util/converters"
import { getPlayerSkills } from "@/db/postgresMainDatabase/schemas/attributes/playerSkills"
import type { TPlayerSkills } from "@/db/postgresMainDatabase/schemas/attributes/playerSkills"
import type { TPlayerSkillsParams } from "@/db/postgresMainDatabase/schemas/attributes/playerSkills" 
import type { TPlayerSkillsRecordBySkillId } from "@/db/postgresMainDatabase/schemas/attributes/playerSkills"

// eslint-disable-next-line @typescript-eslint/no-explicit-any
let cachedData: any = null
const CACHE_TTL = 3_000
let lastUpdated = 0

export async function getPlayerSkillsServer( params: TPlayerSkillsParams): Promise<{
  raw: TPlayerSkills[]
  byKey: TPlayerSkillsRecordBySkillId
  apiPath: string
  atomName: string
}> {
  if (cachedData && Date.now() - lastUpdated < CACHE_TTL) {
    return cachedData
  }
  
  const getPlayerSkillsData = await getPlayerSkills(params)

  const data = getPlayerSkillsData ? (arrayToObjectKey(["skillId"], getPlayerSkillsData) as TPlayerSkillsRecordBySkillId) : {}

  const result = { raw: getPlayerSkillsData, byKey: data, apiPath: `/api/attributes/rpc/get-player-skills/${params.playerId}`, atomName: `playerSkillsAtom`  }

  cachedData = result
  lastUpdated = Date.now()

  return result
}

