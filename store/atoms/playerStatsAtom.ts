import { TPlayerStatsRecordByStatId } from "@/db/postgresMainDatabase/schemas/attributes/playerStats"
import { atom } from "jotai"

export const playerStatsAtom = atom<TPlayerStatsRecordByStatId>({})
