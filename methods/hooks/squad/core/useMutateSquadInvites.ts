// GENERATED CODE - SHOULD BE EDITED MANUALLY TO END CONFIGURATION - hookMutateMethodFetcher.hbs
"use client"

import { useSWRConfig } from "swr"
import { fetchFresh } from "@/providers/swr-fetchers"
import {
  TSquadInvitesRecordById,
  TSquadInvitesFetchParams,
  TSquadInvites,
} from "@/db/postgresMainDatabase/schemas/squad/squadInvites"
import { SQUADINVITES_SWR_KEY } from "@/methods/hooks/squad/core/useFetchSquadInvites"
import { squadInvitesAtom } from "@/store/atoms"
import { useAtomValue } from "jotai"
import { arrayToObjectKey } from "@/methods/functions/util/converters"

export function useMutateSquadInvites(params: TSquadInvitesFetchParams) {
  const { mutate } = useSWRConfig()
  const key = SQUADINVITES_SWR_KEY(params)
  const squadInvites = useAtomValue(squadInvitesAtom)

  function mutateSquadInvites(optimisticParams?: Partial<TSquadInvites>[]) {
    if (!key) return

    if (!optimisticParams) {
      mutate(key, () => fetchFresh(key))
      return
    }

    //MANUAL CODE - START

    /*
      Uzupełnij wartości domyślne dla `optimisticParams`. Wcześniej generator
      wpisywał tu `` (pusty string) dla KAŻDEGO pola, co dla pól liczbowych
      oznaczało `mapId: ""` — bezsensowną daną, która kompilowała się tylko
      dlatego, że `Partial<T>` maskuje typ. Uzupełniaj ręcznie albo zostaw `{}`,
      jeśli nie potrzebujesz defaults.
    */
    const defaultValues = {
      id: ``,
      squadId: ``,
      squadName: ``,
      name: ``,
      nickname: ``,
      secondName: ``,
      createdAt: ``,
      mapId: ``,
      mapTileX: ``,
      mapTileY: ``,
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
