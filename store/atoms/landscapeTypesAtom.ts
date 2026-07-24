import { TWorldLandscapeTypesRecordById } from "@/db/postgresMainDatabase/schemas/world/landscapeTypes"
import { atom } from "jotai"

export const landscapeTypesAtom = atom<TWorldLandscapeTypesRecordById>({})
