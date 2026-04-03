// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetMethodFetcher.hbs

"use client"
import {
  TAllAbilitiesRecordById,
  TAllAbilities,
  TAllAbilitiesParams,
} from "@/db/postgresMainDatabase/schemas/attributes/allAbilities"
import { arrayToObjectKey } from "@/methods/functions/util/converters"
import { allAbilitiesAtom } from "@/store/atoms"
import { useAtomValue, useSetAtom } from "jotai"
import { useEffect } from "react"
import useSWR from "swr"

export function useFetchAllAbilities(params: TAllAbilitiesParams) {
  const setAllAbilities = useSetAtom(allAbilitiesAtom)

  const { data } = useSWR<TAllAbilities[]>(`/api/attributes/rpc/get-all-abilities/${params.playerId}`, {
    refreshInterval: 3000,
  })

  useEffect(() => {
    if (data) {
      const allAbilities = arrayToObjectKey(["id"], data) as TAllAbilitiesRecordById
      setAllAbilities(allAbilities)
    }
  }, [data, setAllAbilities])
}

export function useAllAbilitiesState() {
  return useAtomValue(allAbilitiesAtom)
}
