// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetMethodFetcherServer.hbs
"use server"

import type { TSquadInvitesParams } from "@/db/postgresMainDatabase/schemas/squad/squadInvites"
import type { TSquadInvitesRecordById, TSquadInvites } from "@/db/postgresMainDatabase/schemas/squad/squadInvites"
import { fetchSquadInvitesService } from "@/methods/services/squad/fetchSquadInvitesService"

type TResult = {
  raw: TSquadInvites[]
  byKey: TSquadInvitesRecordById
  apiPath: string
  atomName: string
}

export async function getSquadInvitesServer(
  params: TSquadInvitesParams,
  options?: { forceFresh?: boolean },
): Promise<TResult> {
  const { record } = await fetchSquadInvitesService(params, { forceFresh: options?.forceFresh })

  return {
    raw: record!.raw,
    byKey: record!.byKey,
    apiPath: `/api/squad/rpc/get-squad-invites/${params.playerId}`,
    atomName: `squadInvitesAtom`,
  }
}
