// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetTableByKey.hbs

"use client"
import { TAttributesAbilitiesRecordById, TAttributesAbilities, TAttributesAbilitiesParams } from "@/db/postgresMainDatabase/schemas/attributes/abilities"
import { arrayToObjectKey } from "@/methods/functions/util/converters"
import { abilitiesAtom } from "@/store/atoms"
import { useSetAtom } from "jotai"
import { useEffect } from "react"
import useSWR from "swr"

export function useFetchAttributesAbilitiesByKey( params: TAttributesAbilitiesParams ) {
  const setAttributesAbilities = useSetAtom(abilitiesAtom)
  
  const { data } = useSWR<TAttributesAbilities[]>(`/api/attributes/abilities/${params.id}`, { refreshInterval: 3000 })

  const abilities = data
  ? (arrayToObjectKey(["id"], data) as TAttributesAbilitiesRecordById)
  : undefined

  useEffect(() => {
    if (abilities) {
      setAttributesAbilities(abilities)
    }
  }, [abilities, setAttributesAbilities])

  return { abilities }
}
