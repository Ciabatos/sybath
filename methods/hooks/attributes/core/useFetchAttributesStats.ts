// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetTable.hbs

"use client"
import { TAttributesStatsRecordById } from "@/db/postgresMainDatabase/schemas/attributes/stats"
import { arrayToObjectKey } from "@/methods/functions/util/converters"
import { statsAtom } from "@/store/atoms"
import { useAtomValue, useSetAtom } from "jotai"
import { useEffect, useRef } from "react"
import useSWR from "swr"

export function useFetchAttributesStats() {
  const stats = useAtomValue(statsAtom)
  const setAttributesStats = useSetAtom(statsAtom)

  const { data } = useSWR(`/api/attributes/stats`, { refreshInterval: 3000 })

  const prevDataRef = useRef<unknown>(null)

  useEffect(() => {
    if (data === undefined) return
    if (JSON.stringify(prevDataRef.current) !== JSON.stringify(data)) {
      const index = data ? (arrayToObjectKey(["id"], data) as TAttributesStatsRecordById) : {}
      setAttributesStats(index)
      prevDataRef.current = data
    }
  }, [data, setAttributesStats])

  return { stats }
}
