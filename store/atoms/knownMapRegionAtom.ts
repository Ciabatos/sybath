import { TKnownMapRegionRecordByMapTileXMapTileY } from "@/db/postgresMainDatabase/schemas/world/knownMapRegion"
import { atom } from "jotai"

export const knownMapRegionAtom = atom<TKnownMapRegionRecordByMapTileXMapTileY>({})
