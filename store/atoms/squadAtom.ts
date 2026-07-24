import { TSquadRecordBySquadId } from "@/db/postgresMainDatabase/schemas/squad/squad"
import { atom } from "jotai"

export const squadAtom = atom<TSquadRecordBySquadId>({})
