// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetTableByKey.hbs

"use client"
import { TWorldLandscapeTypesRecordById, TWorldLandscapeTypes, TWorldLandscapeTypesParams } from "@/db/postgresMainDatabase/schemas/world/landscapeTypes"
import { arrayToObjectKey } from "@/methods/functions/util/converters"
import { landscapeTypesAtom } from "@/store/atoms"
import { useAtomValue, useSetAtom } from "jotai"
import { useEffect } from "react"
import useSWR from "swr"

export function useFetchWorldLandscapeTypesByKey( params: TWorldLandscapeTypesParams ) {
  const landscapeTypes = useAtomValue(landscapeTypesAtom)
  const setWorldLandscapeTypes = useSetAtom(landscapeTypesAtom)
  
  const { data } = useSWR<TWorldLandscapeTypes[]>(`/api/world/landscape-types/${params.id}`, { refreshInterval: 3000 })

  useEffect(() => {
    if (data) {
      const index = (arrayToObjectKey(["id"], data) as TWorldLandscapeTypesRecordById)
      setWorldLandscapeTypes(index)
    }
  }, [data, setWorldLandscapeTypes])

  return { landscapeTypes }
}
