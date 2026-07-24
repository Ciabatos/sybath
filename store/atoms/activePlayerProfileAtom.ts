import { TActivePlayerProfileRecordByName } from "@/db/postgresMainDatabase/schemas/players/activePlayerProfile"
import { atom } from "jotai"

export const activePlayerProfileAtom = atom<TActivePlayerProfileRecordByName>({})
