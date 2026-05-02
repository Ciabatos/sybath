// GENERATED CODE - DO EDIT MANUALLY - createNestedPanels.hbs
"use client"
import { Field, FieldLabel } from "@/components/ui/field"
import { Progress } from "@/components/ui/progress"
import { usePlayerEnergyBar } from "@/methods/hooks/players/composite/usePlayerEnergyBar"
import { useId } from "react"
import styles from "./styles/PlayerEnergyBar.module.css"

export default function PlayerEnergyBar() {
  const { playerEnergy } = usePlayerEnergyBar()
  const uniqueId = useId()
  return (
    <div className={styles.panel}>
      {Object.values(playerEnergy).map((energy) => (
        <Field key={uniqueId}>
          <FieldLabel htmlFor='progress-upload'>
            <span>Energy</span>
            <span className='ml-auto'>{energy.currentEnergy}%</span>
          </FieldLabel>
          <Progress
            value={energy.currentEnergy}
            id='progress-upload'
          />
        </Field>
      ))}
    </div>
  )
}
