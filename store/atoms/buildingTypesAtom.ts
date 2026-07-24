import { TBuildingsBuildingTypesRecordById } from "@/db/postgresMainDatabase/schemas/buildings/buildingTypes"
import { atom } from "jotai"

export const buildingTypesAtom = atom<TBuildingsBuildingTypesRecordById>({})
