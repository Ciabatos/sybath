import { TCitiesCityTilesRecordByXY } from "@/db/postgresMainDatabase/schemas/cities/cityTiles"
import { atom } from "jotai"

export const cityTilesAtom = atom<TCitiesCityTilesRecordByXY>({})
