"use client"

import { usePlayerSkills } from "@/methods/hooks/playerSkills/usePlayerSkills"

export default function PlayerSkills() {
  const { playerSkills } = usePlayerSkills()
  console.log("PlayerSkills", playerSkills)
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
