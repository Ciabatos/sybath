"use client"

import { Button } from "@/components/ui/button"
import { usePlayerAbility } from "@/methods/hooks/usePlayerAbility"

export default function PlayerAbilities() {
  const { playerAbilities, handleClickOnPlayerAbility } = usePlayerAbility()

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
        <Button
          key={playerAbility.id}
          className="inventory-slot"
          onClick={() => {
            handleClickOnPlayerAbility(playerAbility.ability_id)
          }}
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
        </Button>
      ))}
    </div>
  )
}
