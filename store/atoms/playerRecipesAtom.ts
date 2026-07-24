import { TPlayerRecipesRecordByItemId } from "@/db/postgresMainDatabase/schemas/items/playerRecipes"
import { atom } from "jotai"

export const playerRecipesAtom = atom<TPlayerRecipesRecordByItemId>({})
