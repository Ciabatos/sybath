// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetTable.hbs

"use client"
import {
  TInventoryInventorySlotTypesRecordById,
  TInventoryInventorySlotTypes,
} from "@/db/postgresMainDatabase/schemas/inventory/inventorySlotTypes"
import { arrayToObjectKey } from "@/methods/functions/util/converters"
import { inventorySlotTypesAtom } from "@/store/atoms"
import { useSetAtom } from "jotai"
import { useEffect } from "react"
import useSWR from "swr"

export function useFetchInventoryInventorySlotTypes() {
  const setInventoryInventorySlotTypes = useSetAtom(inventorySlotTypesAtom)

  const { data } = useSWR<TInventoryInventorySlotTypes[]>(`/api/inventory/inventory-slot-types`, {
    refreshInterval: 3000,
  })

  useEffect(() => {
    if (data) {
      const inventorySlotTypes = arrayToObjectKey(["id"], data) as TInventoryInventorySlotTypesRecordById
      setInventoryInventorySlotTypes(inventorySlotTypes)
    }
  }, [data, setInventoryInventorySlotTypes])
}
