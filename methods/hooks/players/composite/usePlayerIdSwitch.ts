"use client"

import { activePlayerAtom } from "@/store/atoms"
import { useSetAtom } from "jotai"
import { toast } from "sonner"

export function usePlayerIdSwitch() {
  const setActivePlayer = useSetAtom(activePlayerAtom)

  async function switchPlayer(newPlayerId: number) {
    try {
      setActivePlayer(newPlayerId)

      return toast.success("Player id zmieniony na: " + newPlayerId)
    } catch (err) {
      console.error("Unexpected error in usePlayerIdSwitch:", err)
      return "Unexpected error occurred. Please refresh the page."
    }
  }

  return { switchPlayer }
}
