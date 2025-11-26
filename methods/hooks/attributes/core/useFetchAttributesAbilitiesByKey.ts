// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetTableByKey.hbs

"use client"
import { TAttributesAbilitiesRecordById, TAttributesAbilitiesParams } from "@/db/postgresMainDatabase/schemas/attributes/abilities"
import { arrayToObjectKey } from "@/methods/functions/util/converters"
import { abilitiesAtom } from "@/store/atoms"
import { useAtomValue, useSetAtom } from "jotai"
import { useEffect, useRef } from "react"
import useSWR from "swr"

export function useFetchAttributesAbilitiesByKey( params: TAttributesAbilitiesParams ) {
  const abilities = useAtomValue(abilitiesAtom)
  const setAttributesAbilities = useSetAtom(abilitiesAtom)
  
  const { data } = useSWR(`/api/attributes/abilities/${params.id}`, { refreshInterval: 3000 })

  const prevDataRef = useRef<unknown>(null)

  useEffect(() => {
    if (data === undefined) return
    if (JSON.stringify(prevDataRef.current) !== JSON.stringify(data)) {
      const index = data ? (arrayToObjectKey(["id"], data) as TAttributesAbilitiesRecordById) : {}
      setAttributesAbilities(index)
      prevDataRef.current = data
    }
  }, [data, setAttributesAbilities])

  return { abilities }
}
