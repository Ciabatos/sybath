import { TActivePlayerSwitchProfilesRecordById } from "@/db/postgresMainDatabase/schemas/players/activePlayerSwitchProfiles"
import { atom } from "jotai"

export const activePlayerSwitchProfilesAtom = atom<TActivePlayerSwitchProfilesRecordById>({})
