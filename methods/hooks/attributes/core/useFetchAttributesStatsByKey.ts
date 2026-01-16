// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetTableByKey.hbs

"use client"
import { TAttributesStatsRecordById, TAttributesStats, TAttributesStatsParams } from "@/db/postgresMainDatabase/schemas/attributes/stats"
import { arrayToObjectKey } from "@/methods/functions/util/converters"
import { statsAtom } from "@/store/atoms"
import { useSetAtom } from "jotai"
import { useEffect } from "react"
import useSWR from "swr"

export function useFetchAttributesStatsByKey( params: TAttributesStatsParams ) {
  const setAttributesStats = useSetAtom(statsAtom)
  
  const { data } = useSWR<TAttributesStats[]>(`/api/attributes/stats/${params.id}`, { refreshInterval: 3000 })

  useEffect(() => {
    if (data) {
      const stats = arrayToObjectKey(["id"], data) as TAttributesStatsRecordById
      setAttributesStats(stats)
    }
  }, [data, setAttributesStats])
}
