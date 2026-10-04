"use client"

import { useCallback, useMemo, useState } from "react"
import { TradeBoardState, TradeChangePayload, TradeItem, TradeParticipant, TradeSideState } from "./types"

const TRADE_ITEM_MIME = "application/x-trade-item"

function createSideState(slots: number): TradeSideState {
  return {
    gold: 0,
    slots: Array.from({ length: slots }, () => null),
    confirmed: false,
  }
}

export type TDropPayload = {
  side: 1 | 2
  itemId: number
  fromSlotIndex?: number
}

export function useTradeBoard({
  left,
  right,
  offerSlots = 6,
  onChange,
  onAccept,
  onCancel,
}: {
  left: TradeParticipant
  right: TradeParticipant
  offerSlots?: number
  onChange?: (payload: TradeChangePayload) => void
  onAccept?: (payload: TradeChangePayload) => void
  onCancel?: () => void
}) {
  const [board, setBoard] = useState<TradeBoardState>(() => ({
    1: createSideState(left.gold),
    2: createSideState(right.gold),
  }))

  const update = useCallback(
    (updater: (current: TradeBoardState) => TradeBoardState) => {
      setBoard((current) => {
        const next = updater(current)
        onChange?.({ board: next })
        return next
      })
    },
    [onChange],
  )

  const withSide = useCallback(
    (side: 1 | 2, patch: Partial<TradeSideState> | ((state: TradeSideState) => TradeSideState)) => {
      update((current) => {
        const state = current[side]
        return { ...current, [side]: typeof patch === "function" ? patch(state) : { ...state, ...patch } }
      })
    },
    [update],
  )

  const clearSide = useCallback(
    (side: 1 | 2) => {
      withSide(side, (state) => ({
        ...state,
        gold: 0,
        confirmed: false,
        slots: state.slots.map(() => null),
      }))
    },
    [withSide],
  )

  const withdrawSlot = useCallback(
    (side: 1 | 2, slotIndex: number) => {
      withSide(side, (state) => ({
        ...state,
        confirmed: false,
        slots: state.slots.map((slot, index) => (index === slotIndex ? null : slot)),
      }))
    },
    [withSide],
  )

  const setSlotQuantity = useCallback(
    (side: 1 | 2, slotIndex: number, quantity: number) => {
      withSide(side, (state) => ({
        ...state,
        confirmed: false,
        slots: state.slots.map((slot, index) => {
          if (index !== slotIndex || !slot) return slot
          const max = slot.item.maxStack ?? slot.item.quantity
          const next = Math.min(Math.max(1, quantity), max)
          return { item: slot.item, quantity: next }
        }),
      }))
    },
    [withSide],
  )

  const placeItem = useCallback(
    (side: 1 | 2, item: TradeItem, targetSlot?: number) => {
      withSide(side, (state) => {
        const alreadyOffered = state.slots.some((slot) => slot?.item.id === item.id)
        const firstEmpty = state.slots.findIndex((slot) => slot === null)
        const slotIndex = targetSlot ?? firstEmpty

        if (slotIndex < 0) return state

        if (alreadyOffered) {
          return {
            ...state,
            confirmed: false,
            slots: state.slots.map((slot, index) => {
              if (index !== slotIndex || !slot) return slot
              const max = slot.item.maxStack ?? item.quantity
              return { item: slot.item, quantity: Math.min(max, slot.quantity + item.quantity) }
            }),
          }
        }

        return {
          ...state,
          confirmed: false,
          slots: state.slots.map((slot, index) =>
            index === slotIndex ? { item, quantity: Math.min(item.quantity, item.maxStack ?? item.quantity) } : slot,
          ),
        }
      })
    },
    [withSide],
  )

  const setGold = useCallback(
    (side: 1 | 2, amount: number) => {
      withSide(side, (state) => ({
        ...state,
        confirmed: false,
        gold: Math.min(Math.max(0, Math.floor(amount || 0)), side === 1 ? left.gold : right.gold),
      }))
    },
    [left.gold, right.gold, withSide],
  )

  const toggleConfirm = useCallback(
    (side: 1 | 2) => {
      withSide(side, (state) => ({ ...state, confirmed: !state.confirmed }))
    },
    [withSide],
  )

  const reset = useCallback(() => {
    setBoard({ 1: createSideState(left.gold), 2: createSideState(right.gold) })
  }, [left.gold, right.gold, offerSlots])

  const cancel = useCallback(() => {
    reset()
    onCancel?.()
  }, [onCancel, reset])

  const bothConfirmed = board[1].confirmed && board[2].confirmed

  const accept = useCallback(() => {
    if (!bothConfirmed) return
    onAccept?.({ board })
  }, [bothConfirmed, onAccept, board])

  const totals = useMemo(() => {
    const sideTotal = (side: 1 | 2) => {
      const items = board[side].slots.reduce(
        (sum, slot) => sum + (slot ? slot.quantity * (slot.item.price ?? 0) : 0),
        0,
      )
      return items + board[side].gold
    }

    return { 1: sideTotal(1), 2: sideTotal(2) } as const
  }, [board])

  const tradeJson = useCallback((side: 1 | 2, itemId: number, fromSlotIndex?: number) => {
    return JSON.stringify({ side, itemId, fromSlotIndex })
  }, [])

  const parseDrop = useCallback((dataTransfer: DataTransfer): TDropPayload | null => {
    const raw = dataTransfer.getData(TRADE_ITEM_MIME) || dataTransfer.getData("text/plain")
    if (!raw) return null

    try {
      const parsed = JSON.parse(raw) as TDropPayload
      return typeof parsed?.itemId === "number" ? parsed : null
    } catch {
      return null
    }
  }, [])

  return {
    board,
    totals,
    bothConfirmed,
    offerSlots,
    placeItem,
    withdrawSlot,
    setSlotQuantity,
    setGold,
    toggleConfirm,
    accept,
    cancel,
    reset,
    clearSide,
    tradeJson,
    parseDrop,
    mime: TRADE_ITEM_MIME,
  }
}

export type TTradeBoard = ReturnType<typeof useTradeBoard>
