"use client"

import { TTradeSlot } from "@/components/trade/TradeSlot"
import { useFetchItemsItems, useItemsItemsState } from "@/methods/hooks/items/core/useFetchItemsItems"
import { usePlayerId } from "@/methods/hooks/players/composite/usePlayerId"
import { useClickedTrade } from "@/methods/hooks/trade/composite/useClickedTrade"
import { useFetchTradeInventory, useTradeInventoryState } from "@/methods/hooks/trade/core/useFetchTradeInventory"

export function useTrade() {
  const { playerId } = usePlayerId()
  const clickedTrade = useClickedTrade()

  useFetchItemsItems()
  const items = useItemsItemsState()

  useFetchTradeInventory({ playerId, tradeId: clickedTrade })
  const tradeInventory = useTradeInventoryState()

  const combinedTradeInventory = Object.values(tradeInventory).map(
    (tradeInventory): TTradeSlot => ({
      type: "tradeInventory",
      ...tradeInventory,
      ...items[tradeInventory.itemId],
    }),
  )

  return { combinedTradeInventory }
}
