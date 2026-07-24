import { TPlayerKnownPlayersRecordByOtherPlayerId } from "@/db/postgresMainDatabase/schemas/knowledge/playerKnownPlayers"
import { atom } from "jotai"

export const playerKnownPlayersAtom = atom<TPlayerKnownPlayersRecordByOtherPlayerId>({})
