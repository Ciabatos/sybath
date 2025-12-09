// GENERATED CODE - SHOULD BE EDITED MANUALLY TO END CONFIGURATION - hookMutateMethodFetcher.hbs
"use client"

import { TGetPlayerMovementParams, TGetPlayerMovementRecordByXY } from "@/db/postgresMainDatabase/schemas/world/getPlayerMovement"
import { getPlayerMovementAtom } from "@/store/atoms"
import { useAtomValue, useSetAtom } from "jotai"
import useSWR from "swr"

export function useMutateGetPlayerMovement(params: TGetPlayerMovementParams) {
  const { mutate } = useSWR(`/api/world/rpc/get-player-movement/${params.playerId}`)
  const setGetPlayerMovement = useSetAtom(getPlayerMovementAtom)
  const getPlayerMovement = useAtomValue(getPlayerMovementAtom)

  function mutateGetPlayerMovement(optimisticParams: Partial<Record<string, Partial<TGetPlayerMovementRecordByXY[string]>>>) {
    const optimisticData: TGetPlayerMovementRecordByXY = {
      ...getPlayerMovement,
      ...Object.fromEntries(
        Object.entries(optimisticParams).map(([key, val]) => [
          key,
          { ...(getPlayerMovement[key] ?? {}), ...val }, // <-- tutaj domyślny obiekt
        ]),
      ),
    }

    setGetPlayerMovement(optimisticData)
    mutate(undefined, {
      optimisticData,
      rollbackOnError: true,
      revalidate: false,
      populateCache: true,
    })
  }

  return { mutateGetPlayerMovement }
}
