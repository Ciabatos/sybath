"use client"
import { actionTaskInProcessAtom } from "@/store/atoms"
import { useAtomValue, useSetAtom } from "jotai"
import { useEffect, useRef } from "react"
import useSWR from "swr"

export function useFetchActionTaskInProcess() {
  const actionTaskInProcess = useAtomValue(actionTaskInProcessAtom)
  const setActionTaskInProcess = useSetAtom(actionTaskInProcessAtom)
  const { data } = useSWR("/api/map-tiles/action-task-in-process", { refreshInterval: 3000 })

  const prevDataRef = useRef<unknown>(null)

  useEffect(() => {
    if (data === undefined) return
    if (JSON.stringify(prevDataRef.current) !== JSON.stringify(data)) {
      setActionTaskInProcess(data)
      prevDataRef.current = data
    }
  }, [data])

  return { actionTaskInProcess }
}
