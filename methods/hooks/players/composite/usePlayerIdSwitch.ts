"use client"

import { TActivePlayerRecordById } from "@/db/postgresMainDatabase/schemas/players/activePlayer"
import { activePlayerAtom } from "@/store/atoms"
import { useSetAtom } from "jotai"
import { toast } from "sonner"

export function usePlayerIdSwitch() {
  const setActivePlayer = useSetAtom(activePlayerAtom)

  async function switchPlayer(newPlayerId: number) {
    try {
      const activePlayer: TActivePlayerRecordById = {
        [newPlayerId]: {
          id: newPlayerId,
        },
      }

      setActivePlayer(activePlayer)

      return toast.success("Player id zmieniony na: " + newPlayerId)
    } catch (err) {
      console.error("Unexpected error in usePlayerIdSwitch:", err)
      return "Unexpected error occurred. Please refresh the page."
    }
  }

  return { switchPlayer }
}
