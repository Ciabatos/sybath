// GENERATED CODE - SHOULD BE EDITED MANUALLY TO END CONFIGURATION - hookMutateMethodFetcher.hbs
"use client"

import { useSWRConfig } from "swr"
import { fetchFresh } from "@/providers/swr-fetchers"
import {
  TPlayerKnownPlayersRecordByOtherPlayerId,
  TPlayerKnownPlayersFetchParams,
  TPlayerKnownPlayers,
} from "@/db/postgresMainDatabase/schemas/knowledge/playerKnownPlayers"
import { PLAYERKNOWNPLAYERS_SWR_KEY } from "@/methods/hooks/knowledge/core/useFetchPlayerKnownPlayers"
import { playerKnownPlayersAtom } from "@/store/atoms"
import { useAtomValue } from "jotai"
import { arrayToObjectKey } from "@/methods/functions/util/converters"

export function useMutatePlayerKnownPlayers(params: TPlayerKnownPlayersFetchParams) {
  const { mutate } = useSWRConfig()
  const key = PLAYERKNOWNPLAYERS_SWR_KEY(params)
  const playerKnownPlayers = useAtomValue(playerKnownPlayersAtom)

  function mutatePlayerKnownPlayers(optimisticParams?: Partial<TPlayerKnownPlayers>[]) {
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
      otherPlayerId: ``,
      name: ``,
      secondName: ``,
      nickname: ``,
      imagePortrait: ``,
      mapId: ``,
      x: ``,
      y: ``,
      imageMap: ``,
    }

    //MANUAL CODE - END

    const dataWithDefaults = optimisticParams.map((val) => ({
      ...defaultValues,
      ...val,
    }))

    const newObj = arrayToObjectKey(["otherPlayerId"], dataWithDefaults) as TPlayerKnownPlayersRecordByOtherPlayerId

    const optimisticDataMergeWithOldData: TPlayerKnownPlayersRecordByOtherPlayerId = {
      ...playerKnownPlayers,
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

  return { mutatePlayerKnownPlayers }
}
