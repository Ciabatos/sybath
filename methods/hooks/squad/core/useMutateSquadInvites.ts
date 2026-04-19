// GENERATED CODE - SHOULD BE EDITED MANUALLY TO END CONFIGURATION - hookMutateMethodFetcher.hbs
"use client"

import { useSWRConfig } from "swr"
import { fetchFresh } from "@/providers/swr-fetchers"
import {
  TSquadInvitesRecordById,
  TSquadInvitesParams,
  TSquadInvites,
} from "@/db/postgresMainDatabase/schemas/squad/squadInvites"
import { squadInvitesAtom } from "@/store/atoms"
import { useAtomValue } from "jotai"
import { arrayToObjectKey } from "@/methods/functions/util/converters"

export function useMutateSquadInvites(params: TSquadInvitesParams) {
  const { mutate } = useSWRConfig()
  const key = `/api/squad/rpc/get-squad-invites/${params.playerId}`
  const squadInvites = useAtomValue(squadInvitesAtom)

  function mutateSquadInvites(optimisticParams?: Partial<TSquadInvites>[]) {
    if (!optimisticParams) {
      mutate(key, () => fetchFresh(key))
      return
    }

    //MANUAL CODE - START

    const defaultValues = {
      id: ``,
      description: ``,
      name: ``,
      nickname: ``,
      secondName: ``,
      createdAt: ``,
    }

    //MANUAL CODE - END

    const dataWithDefaults = optimisticParams.map((val) => ({
      ...defaultValues,
      ...val,
    }))

    const newObj = arrayToObjectKey(["id"], dataWithDefaults) as TSquadInvitesRecordById

    const optimisticDataMergeWithOldData: TSquadInvitesRecordById = {
      ...squadInvites,
      ...newObj,
    }

    const optimisticDataMergeWithOldDataArray = Object.values(optimisticDataMergeWithOldData)

    mutate(key, () => fetchFresh(key), {
      optimisticData: optimisticDataMergeWithOldDataArray,
      rollbackOnError: true,
      revalidate: false,
      populateCache: true,
    })
  }

  return { mutateSquadInvites }
}
