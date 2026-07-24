import { TPlayersOnTileRecordByOtherPlayerId } from "@/db/postgresMainDatabase/schemas/world/playersOnTile"
import { atom } from "jotai"

export const playersOnTileAtom = atom<TPlayersOnTileRecordByOtherPlayerId>({})
