import { TOtherPlayerStatsRecordByStatId } from "@/db/postgresMainDatabase/schemas/attributes/otherPlayerStats"
import { atom } from "jotai"

export const otherPlayerStatsAtom = atom<TOtherPlayerStatsRecordByStatId>({})
