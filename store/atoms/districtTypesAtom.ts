import { TDistrictsDistrictTypesRecordById } from "@/db/postgresMainDatabase/schemas/districts/districtTypes"
import { atom } from "jotai"

export const districtTypesAtom = atom<TDistrictsDistrictTypesRecordById>({})
