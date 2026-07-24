import { TKnownMapTilesResourcesOnTileRecordByMapTilesResourceId } from "@/db/postgresMainDatabase/schemas/world/knownMapTilesResourcesOnTile"
import { atom } from "jotai"

export const knownMapTilesResourcesOnTileAtom = atom<TKnownMapTilesResourcesOnTileRecordByMapTilesResourceId>({})
