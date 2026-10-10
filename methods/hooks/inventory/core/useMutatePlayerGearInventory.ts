// GENERATED CODE - SHOULD BE EDITED MANUALLY TO END CONFIGURATION - hookMutateMethodFetcher.hbs
"use client"

import { useSWRConfig } from "swr"
import { fetchFresh } from "@/providers/swr-fetchers"
import {
  TPlayerGearInventoryRecordBySlotId,
  TPlayerGearInventoryFetchParams,
  TPlayerGearInventory,
} from "@/db/postgresMainDatabase/schemas/inventory/playerGearInventory"
import { PLAYERGEARINVENTORY_SWR_KEY } from "@/methods/hooks/inventory/core/useFetchPlayerGearInventory"
import { playerGearInventoryAtom } from "@/store/atoms"
import { useAtomValue } from "jotai"
import { arrayToObjectKey } from "@/methods/functions/util/converters"

export function useMutatePlayerGearInventory(params: TPlayerGearInventoryFetchParams) {
  const { mutate } = useSWRConfig()
  const key = PLAYERGEARINVENTORY_SWR_KEY(params)
  const playerGearInventory = useAtomValue(playerGearInventoryAtom)

  function mutatePlayerGearInventory(optimisticParams?: Partial<TPlayerGearInventory>[]) {
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
      slotId: ``,
      containerId: ``,
      inventoryContainerTypeId: ``,
      inventorySlotTypeId: ``,
      itemId: ``,
      name: ``,
      quantity: ``,
    }

    //MANUAL CODE - END

    const dataWithDefaults = optimisticParams.map((val) => ({
      ...defaultValues,
      ...val,
    }))

    const newObj = arrayToObjectKey(["slotId"], dataWithDefaults) as TPlayerGearInventoryRecordBySlotId

    const optimisticDataMergeWithOldData: TPlayerGearInventoryRecordBySlotId = {
      ...playerGearInventory,
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

  return { mutatePlayerGearInventory }
}
