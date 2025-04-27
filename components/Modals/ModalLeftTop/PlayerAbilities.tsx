"use client"

import { useFetchPlayerAbilities } from "@/methods/hooks/useFetchPlayerAbilities"
import { playerAbilitiesAtom } from "@/store/atoms"
import { useAtomValue } from "jotai"

export default function PlayerAbilities() {
  useFetchPlayerAbilities()
  const playerAbilities = useAtomValue(playerAbilitiesAtom)

  return (
    <div
      className="inventory-grid"
      style={{
        display: "grid",
        gridTemplateColumns: `repeat(auto-fit, minmax(100px, 1fr))`, // Dynamiczne kolumny
        gap: "8px",
        width: "100%",
      }}>
      {playerAbilities.map((playerAbility) => (
        <div
          key={playerAbility.id}
          className="inventory-slot"
          style={{
            backgroundColor: "lightgray",
            display: "flex",
            alignItems: "center",
            justifyContent: "center",
            border: "1px solid #ccc",
            borderRadius: "4px",
            minHeight: "50px",
          }}>
          {playerAbility.name}
        </div>
      ))}
    </div>
  )
}
