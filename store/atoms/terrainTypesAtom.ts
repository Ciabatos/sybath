import { TWorldTerrainTypesRecordById } from "@/db/postgresMainDatabase/schemas/world/terrainTypes"
import { atom } from "jotai"

export const terrainTypesAtom = atom<TWorldTerrainTypesRecordById>({})
