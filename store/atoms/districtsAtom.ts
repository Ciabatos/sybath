import { TDistrictsDistrictsRecordByMapTileXMapTileY } from "@/db/postgresMainDatabase/schemas/districts/districts"
import { atom } from "jotai"

export const districtsAtom = atom<TDistrictsDistrictsRecordByMapTileXMapTileY>({})
