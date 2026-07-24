

import { TActivePlayerRecordById } from "@/db/postgresMainDatabase/schemas/players/activePlayer"
import { atom } from "jotai"

export const activePlayerAtom = atom<TActivePlayerRecordById>({})
