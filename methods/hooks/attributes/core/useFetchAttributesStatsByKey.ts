// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetTableByKey.hbs

"use client"
import {
  TAttributesStatsRecordById,
  TAttributesStats,
  TAttributesStatsParamsFetchParams,
} from "@/db/postgresMainDatabase/schemas/attributes/stats"
import { arrayToObjectKey } from "@/methods/functions/util/converters"
import { statsAtom } from "@/store/atoms"
import { useAtomValue, useSetAtom } from "jotai"
import { useEffect } from "react"
import useSWR from "swr"

/*
  Wspólny klucz SWR. Eksportowany, bo `useMutateAttributesStats` musi
  budować DOKŁADNIE tę samą wartość — inaczej SWR widzi dwa różne zasoby,
  a dopasowanie optimistic update'ów po cichu przestaje działać.

  Zwraca `null`, gdy brakuje któregokolwiek parametru. SWR traktuje klucz
  `null` jako "nie pobieraj" i nie wykonuje requestu.
*/
export const ATTRIBUTESSTATS_SWR_KEY_BY_KEY = (params: TAttributesStatsParamsFetchParams) =>
  params.id != null ? `/api/attributes/stats/${params.id}` : null

export function useFetchAttributesStatsByKey(params: TAttributesStatsParamsFetchParams) {
  const setAttributesStats = useSetAtom(statsAtom)

  const { data } = useSWR<TAttributesStats[]>(ATTRIBUTESSTATS_SWR_KEY_BY_KEY(params), {
    refreshInterval: 3000,
  })

  useEffect(() => {
    if (data) {
      const stats = arrayToObjectKey(["id"], data) as TAttributesStatsRecordById
      setAttributesStats(stats)
    }
  }, [data, setAttributesStats])
}

export function useAttributesStatsState() {
  return useAtomValue(statsAtom)
}
