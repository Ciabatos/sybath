// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetTable.hbs

"use client"
import {
  TAttributesAbilitiesRecordById,
  TAttributesAbilities,
} from "@/db/postgresMainDatabase/schemas/attributes/abilities"
import { arrayToObjectKey } from "@/methods/functions/util/converters"
import { abilitiesAtom } from "@/store/atoms"
import { useSetAtom } from "jotai"
import { useEffect } from "react"
import useSWR from "swr"

export function useFetchAttributesAbilities() {
  const setAttributesAbilities = useSetAtom(abilitiesAtom)

  const { data } = useSWR<TAttributesAbilities[]>(`/api/attributes/abilities`, { refreshInterval: 3000 })

  useEffect(() => {
    if (data) {
      const abilities = arrayToObjectKey(["id"], data) as TAttributesAbilitiesRecordById
      setAttributesAbilities(abilities)
    }
  }, [data, setAttributesAbilities])
}
