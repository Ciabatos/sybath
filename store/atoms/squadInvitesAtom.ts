import { TSquadInvitesRecordById } from "@/db/postgresMainDatabase/schemas/squad/squadInvites"
import { atom } from "jotai"

export const squadInvitesAtom = atom<TSquadInvitesRecordById>({})
