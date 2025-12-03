"use client"

import { Button } from "@/components/ui/button"
import { useModalLeftTopBar } from "@/methods/hooks/modals/useModalLeftTopBar"
import { usePlayerAbility } from "@/methods/hooks/players/composite/usePlayerAbility"
import { EPanels } from "@/types/enumeration/EPanels"

export default function PanelPlayerAbilities() {
  const { playerAbilities, selectAbility } = usePlayerAbility()
  const { setStatus } = useModalLeftTopBar()

  function handleClickOnPlayerAbility(abilityId: number) {
    selectAbility(abilityId)
    setStatus(EPanels.PanelActionAbility)
  }

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
