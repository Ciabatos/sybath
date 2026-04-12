"use client"
import { useModalRightCenter } from "@/methods/hooks/modals/useModalRightCenter"
import { EPanelsRightCenter } from "@/types/enumeration/EPanelsRightCenter"
import styles from "./styles/Ability.module.css"

interface TAbilityProps {
  icon: React.ReactNode
  name: string
  description: string
  value: number
  disabled?: boolean
}

export default function Ability({ icon, name, description, value, disabled }: TAbilityProps) {
  const { openModalRightCenter } = useModalRightCenter()

  function openAbility(name: string, disabled?: boolean) {
    if (disabled) return
    if (name === "Craft") {
      openModalRightCenter(EPanelsRightCenter.Crafting)
    }
  }

  return (
    <div
      onClick={() => openAbility(name, disabled)}
      className={`${styles.abilityItem} ${value <= 0 ? styles.disabled : ""}`}
    >
      <div className={styles.abilityIcon}>
        <span className={styles.iconEmoji}>{icon}</span>
        <div className={styles.cooldownBadge}>{`X`}</div>
      </div>
      <div className={styles.abilityContent}>
        <div className={styles.abilityHeader}>
          <h3 className={styles.abilityName}>{name}</h3>
        </div>
      </div>
      <p className={styles.abilityDescription}>{description}</p>
    </div>
  )
}
