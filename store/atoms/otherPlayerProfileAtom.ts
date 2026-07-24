import { TOtherPlayerProfileRecordByName } from "@/db/postgresMainDatabase/schemas/players/otherPlayerProfile"
import { atom } from "jotai"

export const otherPlayerProfileAtom = atom<TOtherPlayerProfileRecordByName>({})
