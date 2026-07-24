import { TKnownMapTilesRecordByXY } from "@/db/postgresMainDatabase/schemas/world/knownMapTiles"
import { atom } from "jotai"

export const knownMapTilesAtom = atom<TKnownMapTilesRecordByXY>({})
