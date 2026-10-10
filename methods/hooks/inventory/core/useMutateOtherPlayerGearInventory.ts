// GENERATED CODE - SHOULD BE EDITED MANUALLY TO END CONFIGURATION - hookMutateMethodFetcher.hbs
"use client"

import { useSWRConfig } from "swr"
import { fetchFresh } from "@/providers/swr-fetchers"
import {
  TOtherPlayerGearInventoryRecordBySlotId,
  TOtherPlayerGearInventoryFetchParams,
  TOtherPlayerGearInventory,
} from "@/db/postgresMainDatabase/schemas/inventory/otherPlayerGearInventory"
import { OTHERPLAYERGEARINVENTORY_SWR_KEY } from "@/methods/hooks/inventory/core/useFetchOtherPlayerGearInventory"
import { otherPlayerGearInventoryAtom } from "@/store/atoms"
import { useAtomValue } from "jotai"
import { arrayToObjectKey } from "@/methods/functions/util/converters"

export function useMutateOtherPlayerGearInventory(params: TOtherPlayerGearInventoryFetchParams) {
  const { mutate } = useSWRConfig()
  const key = OTHERPLAYERGEARINVENTORY_SWR_KEY(params)
  const otherPlayerGearInventory = useAtomValue(otherPlayerGearInventoryAtom)

  function mutateOtherPlayerGearInventory(optimisticParams?: Partial<TOtherPlayerGearInventory>[]) {
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

    const newObj = arrayToObjectKey(["slotId"], dataWithDefaults) as TOtherPlayerGearInventoryRecordBySlotId

    const optimisticDataMergeWithOldData: TOtherPlayerGearInventoryRecordBySlotId = {
      ...otherPlayerGearInventory,
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

  return { mutateOtherPlayerGearInventory }
}
