import { TPlayerMapRecordByMapId } from "@/db/postgresMainDatabase/schemas/world/playerMap"
import { atom } from "jotai"

export const playerMapAtom = atom<TPlayerMapRecordByMapId>({})
