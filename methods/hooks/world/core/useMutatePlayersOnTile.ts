// GENERATED CODE - SHOULD BE EDITED MANUALLY TO END CONFIGURATION - hookMutateMethodFetcher.hbs
"use client"

import { useSWRConfig } from "swr"
import { fetchFresh } from "@/providers/swr-fetchers"
import {
  TPlayersOnTileRecordByOtherPlayerId,
  TPlayersOnTileFetchParams,
  TPlayersOnTile,
} from "@/db/postgresMainDatabase/schemas/world/playersOnTile"
import { PLAYERSONTILE_SWR_KEY } from "@/methods/hooks/world/core/useFetchPlayersOnTile"
import { playersOnTileAtom } from "@/store/atoms"
import { useAtomValue } from "jotai"
import { arrayToObjectKey } from "@/methods/functions/util/converters"

export function useMutatePlayersOnTile(params: TPlayersOnTileFetchParams) {
  const { mutate } = useSWRConfig()
  const key = PLAYERSONTILE_SWR_KEY(params)
  const playersOnTile = useAtomValue(playersOnTileAtom)

  function mutatePlayersOnTile(optimisticParams?: Partial<TPlayersOnTile>[]) {
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
      squadId: ``,
      squadName: ``,
      squadImagePortrait: ``,
    }

    //MANUAL CODE - END

    const dataWithDefaults = optimisticParams.map((val) => ({
      ...defaultValues,
      ...val,
    }))

    const newObj = arrayToObjectKey(["otherPlayerId"], dataWithDefaults) as TPlayersOnTileRecordByOtherPlayerId

    const optimisticDataMergeWithOldData: TPlayersOnTileRecordByOtherPlayerId = {
      ...playersOnTile,
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

  return { mutatePlayersOnTile }
}
