"use client"

import { TPlayerVisibleMapDataById } from "@/db/postgresMainDatabase/schemas/map/functions/playerVisibleMapData"
import type { TMapTile } from "@/db/postgresMainDatabase/schemas/map/tables/mapTiles"
import { TPlayerInventories } from "@/db/postgresMainDatabase/schemas/players/tables/playerInventories"
import { TJoinedMapTile } from "@/methods/functions/joinMapTiles"
import type { TClickedTile } from "@/methods/hooks/useMapTileClick"
import { TMovmentPath } from "@/methods/hooks/useMapTilesPath"
import { EMapTilesActionStatus } from "@/types/enumeration/MapTilesActionStatusEnum"
import { atom } from "jotai"

//Map
export const mapTilesAtom = atom<TMapTile[]>([])
export const joinedMapTilesAtom = atom<Record<string, TJoinedMapTile>>({})
export const playerVisibleMapDataAtom = atom<TPlayerVisibleMapDataById>({})
export const clickedTileAtom = atom<TClickedTile>({ x: 1, y: 1 })
export const mapTilesActionStatusAtom = atom<EMapTilesActionStatus>(EMapTilesActionStatus.Inactive)
export const mapTilesMovmentPathAtom = atom<TMovmentPath[]>([])
export const mapTilesGuardAreaAtom = atom<TJoinedMapTile[]>([])

//Player
export const playerInventoryAtom = atom<TPlayerInventories>()
