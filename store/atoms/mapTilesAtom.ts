import { TWorldMapTilesRecordByXY } from "@/db/postgresMainDatabase/schemas/world/mapTiles"
import { atom } from "jotai"

export const mapTilesAtom = atom<TWorldMapTilesRecordByXY>({})
