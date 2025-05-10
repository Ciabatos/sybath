"use client"

import { useFetchPlayerSkills } from "@/methods/hooks/fetchers/useFetchPlayerSkills"
import { playerSkillsAtom } from "@/store/atoms"
import { useAtomValue } from "jotai"

export default function PlayerSkills() {
  useFetchPlayerSkills()
  const playerSkills = useAtomValue(playerSkillsAtom)

  return (
    <div
      className="inventory-grid"
      style={{
        display: "grid",
        gridTemplateColumns: `repeat(auto-fit, minmax(100px, 1fr))`, // Dynamiczne kolumny
        gap: "8px",
        width: "100%",
      }}>
      {playerSkills.map((playerSkill) => (
        <div
          key={playerSkill.id}
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
          {playerSkill.name}
        </div>
      ))}
    </div>
  )
}
