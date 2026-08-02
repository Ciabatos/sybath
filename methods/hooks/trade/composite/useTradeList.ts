"use client"

import { usePlayerId } from "@/methods/hooks/players/composite/usePlayerId"
import { useFetchTrades, useTradesState } from "@/methods/hooks/trade/core/useFetchTrades"

export function useTradeList() {
  const { playerId } = usePlayerId()

  useFetchTrades({ playerId })
  const trades = useTradesState()

  return { trades }
}
