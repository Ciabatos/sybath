// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetTable.hbs

"use client"
import { TAttributesStatsRecordById, TAttributesStats } from "@/db/postgresMainDatabase/schemas/attributes/stats"
import { arrayToObjectKey } from "@/methods/functions/util/converters"
import { statsAtom } from "@/store/atoms"
import { useAtomValue, useSetAtom } from "jotai"
import { useEffect } from "react"
import useSWR from "swr"

export function useFetchAttributesStats() {
  const stats = useAtomValue(statsAtom)
  const setAttributesStats = useSetAtom(statsAtom)

  const { data } = useSWR<TAttributesStats[]>(`/api/attributes/stats`, { refreshInterval: 3000 })

  useEffect(() => {
    if (data) {
      const index = arrayToObjectKey(["id"], data) as TAttributesStatsRecordById
      setAttributesStats(index)
    }
  }, [data, setAttributesStats])

  return { stats }
}
