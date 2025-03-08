"use client"

import type { TMapTiles } from "@/db/postgresMainDatabase/schemas/map/tables/mapTiles"
import type { TjoinedMapTile } from "@/methods/functions/joinMapTilesServer"
import type { TClickedTile } from "@/methods/hooks/useClickTile"
import { EMapTilesActionStatus } from "@/types/enumeration/MapTilesActionStatusEnum"
import { atom } from "jotai"

export const mapTilesAtom = atom<TMapTiles[]>([])
export const joinedMapTilesAtom = atom<Record<string, TjoinedMapTile>>({})
export const clickedTileAtom = atom<TClickedTile>({ x: 1, y: 1 })
export const mapTilesActionStatusAtom = atom<EMapTilesActionStatus>(EMapTilesActionStatus.Inactive)
