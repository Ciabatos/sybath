

import { TKnownMapTilesResourcesOnMapRecordByMapTileXMapTileY } from "@/db/postgresMainDatabase/schemas/world/knownMapTilesResourcesOnMap"
import { atom } from "jotai"

export const knownMapTilesResourcesOnMapAtom = atom<TKnownMapTilesResourcesOnMapRecordByMapTileXMapTileY>({})
