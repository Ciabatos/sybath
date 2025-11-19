// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetTable.hbs

"use client"
import { TAttributesAbilitiesRecordById } from "@/db/postgresMainDatabase/schemas/attributes/abilities"
import { arrayToObjectKeyId } from "@/methods/functions/util/converters"
import { abilitiesAtom } from "@/store/atoms"
import { useAtomValue, useSetAtom } from "jotai"
import { useEffect, useRef } from "react"
import useSWR from "swr"

export function useFetchAbilities() {
  const abilities = useAtomValue(abilitiesAtom)
  const setAbilities = useSetAtom(abilitiesAtom)

  const { data } = useSWR(`/api/attributes/abilities`, { refreshInterval: 3000 })

  const prevDataRef = useRef<unknown>(null)

  useEffect(() => {
    if (data === undefined) return
    if (JSON.stringify(prevDataRef.current) !== JSON.stringify(data)) {
      const index = data ? (arrayToObjectKeyId("id", data) as TAttributesAbilitiesRecordById) : {}
      setAbilities(index)
      prevDataRef.current = data
    }
  }, [data, setAbilities])

  return { abilities }
}
