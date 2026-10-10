// GENERATED CODE - SHOULD BE EDITED MANUALLY TO END CONFIGURATION - hookMutateMethodFetcher.hbs
"use client"

import { useSWRConfig } from "swr"
import { fetchFresh } from "@/providers/swr-fetchers"
import {
  TPlayerInventoryRecordBySlotId,
  TPlayerInventoryFetchParams,
  TPlayerInventory,
} from "@/db/postgresMainDatabase/schemas/inventory/playerInventory"
import { PLAYERINVENTORY_SWR_KEY } from "@/methods/hooks/inventory/core/useFetchPlayerInventory"
import { playerInventoryAtom } from "@/store/atoms"
import { useAtomValue } from "jotai"
import { arrayToObjectKey } from "@/methods/functions/util/converters"

export function useMutatePlayerInventory(params: TPlayerInventoryFetchParams) {
  const { mutate } = useSWRConfig()
  const key = PLAYERINVENTORY_SWR_KEY(params)
  const playerInventory = useAtomValue(playerInventoryAtom)

  function mutatePlayerInventory(optimisticParams?: Partial<TPlayerInventory>[]) {
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

    const newObj = arrayToObjectKey(["slotId"], dataWithDefaults) as TPlayerInventoryRecordBySlotId

    const optimisticDataMergeWithOldData: TPlayerInventoryRecordBySlotId = {
      ...playerInventory,
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

  return { mutatePlayerInventory }
}
