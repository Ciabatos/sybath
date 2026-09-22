// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetMethodFetcherServer.hbs
"use server"

import type { TPlayerEnergyParams } from "@/db/postgresMainDatabase/schemas/attributes/playerEnergy"
import type {
  TPlayerEnergyRecordByLastRegeneratedAt,
  TPlayerEnergy,
} from "@/db/postgresMainDatabase/schemas/attributes/playerEnergy"
import { fetchPlayerEnergyService } from "@/methods/services/attributes/fetchPlayerEnergyService"

type TResult = {
  raw: TPlayerEnergy[]
  byKey: TPlayerEnergyRecordByLastRegeneratedAt
  apiPath: string
  atomName: string
}

export async function getPlayerEnergyServer(
  params: TPlayerEnergyParams,
  options?: { forceFresh?: boolean },
): Promise<TResult> {
  const { record } = await fetchPlayerEnergyService(params, { forceFresh: options?.forceFresh })

  return {
    raw: record!.raw,
    byKey: record!.byKey,
    apiPath: `/api/attributes/rpc/get-player-energy/${params.playerId}`,
    atomName: `playerEnergyAtom`,
  }
}
