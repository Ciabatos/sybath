"use client"

import { Axe, Coins, Gem, Scroll, Shield, Sparkles } from "lucide-react"
import { useState } from "react"
import { TradeWindow, TTradeWindowProps } from "./TradeWindow"
import { TradeChangePayload, TradeParticipant } from "./types"

const myItems = [
  {
    id: 101,
    name: "Rusty Axe",
    description: "It has seen better wars.",
    quantity: 1,
    price: 25,
    rarity: "common" as const,
    icon: <Axe />,
  },
  {
    id: 102,
    name: "Leather Scroll",
    description: "A recipe you cannot read.",
    quantity: 4,
    maxStack: 10,
    price: 8,
    rarity: "uncommon" as const,
    icon: <Scroll />,
  },
  {
    id: 103,
    name: "Iron Shield",
    description: "Dents, but holds.",
    quantity: 1,
    price: 120,
    rarity: "rare" as const,
    icon: <Shield />,
  },
  { id: 104, name: "Mana Potion", quantity: 12, maxStack: 20, price: 4, rarity: "common" as const, icon: <Sparkles /> },
  { id: 105, name: "Gold Coins", quantity: 1, price: 60, rarity: "uncommon" as const, icon: <Coins /> },
  { id: 106, name: "Ruby", quantity: 7, maxStack: 10, price: 15, rarity: "epic" as const, icon: <Gem /> },
]

const otherItems = [
  {
    id: 201,
    name: "Oak Staff",
    description: "Splitting or spellcasting. Hard to say.",
    quantity: 1,
    price: 90,
    rarity: "rare" as const,
    icon: <Sparkles />,
  },
  { id: 202, name: "Silver Ore", quantity: 5, maxStack: 10, price: 22, rarity: "common" as const, icon: <Gem /> },
  {
    id: 203,
    name: "Traveler's Rations",
    quantity: 3,
    maxStack: 8,
    price: 10,
    rarity: "common" as const,
    icon: <Scroll />,
  },
  { id: 204, name: "Warded Amulet", quantity: 1, price: 200, rarity: "legendary" as const, icon: <Gem /> },
]

const initialLeft: TradeParticipant = { id: 1, name: "Aldric", level: 12, gold: 500, inventory: myItems }
const initialRight: TradeParticipant = { id: 2, name: "Brynn", level: 14, gold: 820, inventory: otherItems }

export function TradeWindowDemo() {
  const [log, setLog] = useState<string[]>([])

  const push = (line: string) => setLog((current) => [line, ...current].slice(0, 6))

  const props: TTradeWindowProps = {
    left: initialLeft,
    right: initialRight,
    selfSide: 1,
    offerSlots: 6,
    onChange: ({ board }: TradeChangePayload) => {
      push(
        `offer -> you: ${board[1].slots.filter(Boolean).length} items / ${board[1].gold}g, them: ${board[2].slots.filter(Boolean).length} items / ${board[2].gold}g`,
      )
    },
    onAccept: ({ board }: TradeChangePayload) => {
      push(`trade accepted with ${board[1].gold}g and ${board[2].gold}g`)
    },
    onCancel: () => push("trade cancelled"),
  }

  return (
    <div style={{ display: "flex", flexDirection: "column", gap: "1rem", padding: "1.5rem" }}>
      <TradeWindow {...props} />

      <pre
        style={{
          margin: 0,
          border: "2px solid #4a3426",
          borderRadius: 6,
          background: "#0c0805",
          padding: "0.75rem",
          color: "#a08560",
          fontSize: "0.7rem",
        }}
      >
        {log.length ? log.join("\n") : "Drag items into offer slots, adjust gold, confirm, accept."}
      </pre>
    </div>
  )
}

export default TradeWindowDemo
