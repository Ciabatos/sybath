import { TOtherSquadPlayersProfilesRecordByOtherPlayerId } from "@/db/postgresMainDatabase/schemas/squad/otherSquadPlayersProfiles"
import { atom } from "jotai"

export const otherSquadPlayersProfilesAtom = atom<TOtherSquadPlayersProfilesRecordByOtherPlayerId>({})
