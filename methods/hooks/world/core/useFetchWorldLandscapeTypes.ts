// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetTable.hbs

"use client"
import {
  TWorldLandscapeTypesRecordById,
  TWorldLandscapeTypes,
} from "@/db/postgresMainDatabase/schemas/world/landscapeTypes"
import { arrayToObjectKey } from "@/methods/functions/util/converters"
import { landscapeTypesAtom } from "@/store/atoms"
import { useAtomValue, useSetAtom } from "jotai"
import { useEffect } from "react"
import useSWR from "swr"

export function useFetchWorldLandscapeTypes() {
  const landscapeTypes = useAtomValue(landscapeTypesAtom)
  const setWorldLandscapeTypes = useSetAtom(landscapeTypesAtom)

  const { data } = useSWR<TWorldLandscapeTypes[]>(`/api/world/landscape-types`, { refreshInterval: 3000 })

  useEffect(() => {
    if (data) {
      const index = arrayToObjectKey(["id"], data) as TWorldLandscapeTypesRecordById
      setWorldLandscapeTypes(index)
    }
  }, [data, setWorldLandscapeTypes])

  return { landscapeTypes }
}
