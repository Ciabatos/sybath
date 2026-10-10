// GENERATED CODE - SHOULD BE EDITED MANUALLY TO END CONFIGURATION - hookMutateMethodFetcher.hbs
"use client"

import { useSWRConfig } from "swr"
import { fetchFresh } from "@/providers/swr-fetchers"
import {
  TOtherSquadPlayersProfilesRecordByOtherPlayerId,
  TOtherSquadPlayersProfilesFetchParams,
  TOtherSquadPlayersProfiles,
} from "@/db/postgresMainDatabase/schemas/squad/otherSquadPlayersProfiles"
import { OTHERSQUADPLAYERSPROFILES_SWR_KEY } from "@/methods/hooks/squad/core/useFetchOtherSquadPlayersProfiles"
import { otherSquadPlayersProfilesAtom } from "@/store/atoms"
import { useAtomValue } from "jotai"
import { arrayToObjectKey } from "@/methods/functions/util/converters"

export function useMutateOtherSquadPlayersProfiles(params: TOtherSquadPlayersProfilesFetchParams) {
  const { mutate } = useSWRConfig()
  const key = OTHERSQUADPLAYERSPROFILES_SWR_KEY(params)
  const otherSquadPlayersProfiles = useAtomValue(otherSquadPlayersProfilesAtom)

  function mutateOtherSquadPlayersProfiles(optimisticParams?: Partial<TOtherSquadPlayersProfiles>[]) {
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
      imageMap: ``,
      imagePortrait: ``,
    }

    //MANUAL CODE - END

    const dataWithDefaults = optimisticParams.map((val) => ({
      ...defaultValues,
      ...val,
    }))

    const newObj = arrayToObjectKey(
      ["otherPlayerId"],
      dataWithDefaults,
    ) as TOtherSquadPlayersProfilesRecordByOtherPlayerId

    const optimisticDataMergeWithOldData: TOtherSquadPlayersProfilesRecordByOtherPlayerId = {
      ...otherSquadPlayersProfiles,
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

  return { mutateOtherSquadPlayersProfiles }
}
