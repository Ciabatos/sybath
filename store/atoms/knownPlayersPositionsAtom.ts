import { TKnownPlayersPositionsRecordByXY } from "@/db/postgresMainDatabase/schemas/world/knownPlayersPositions"
import { atom } from "jotai"

export const knownPlayersPositionsAtom = atom<TKnownPlayersPositionsRecordByXY>({})
