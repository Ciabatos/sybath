import { TSquadPlayersProfilesRecordByOtherPlayerId } from "@/db/postgresMainDatabase/schemas/squad/squadPlayersProfiles"
import { atom } from "jotai"

export const squadPlayersProfilesAtom = atom<TSquadPlayersProfilesRecordByOtherPlayerId>({})
