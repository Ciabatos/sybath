import { TAttributesStatsRecordById } from "@/db/postgresMainDatabase/schemas/attributes/stats"
import { atom } from "jotai"

export const statsAtom = atom<TAttributesStatsRecordById>({})
