"use client"

import { TInventorySlot } from "@/components/inventory/InventorySlot"
import getIcon from "@/methods/functions/icons/getIcon"
import styles from "./styles/InventoryInspector.module.css"

type TProps = {
  slot: TInventorySlot | null
  emptyHint: string
}

/**
 * Pasek szczegółów klikniętego przedmiotu. Na desktopie jest uzupełnieniem
 * tooltipa, na mobile — głównym sposobem odczytania nazwy i opisu, bo dotknięcie
 * slotu od razu startuje przeciąganie.
 */
export function InventoryInspector({ slot, emptyHint }: TProps) {
  if (!slot) {
    return (
      <div className={styles.inspector}>
        <p className={styles.idle}>{emptyHint}</p>
      </div>
    )
  }

  const quantity = slot.quantity || 0

  return (
    <div className={styles.inspector}>
      <span className={styles.icon}>{getIcon(slot.image)}</span>

      <div className={styles.body}>
        <div className={styles.titleRow}>
          <h4 className={styles.name}>{slot.name}</h4>
          {quantity > 1 && <span className={styles.quantity}>x{quantity}</span>}
        </div>
        <p className={styles.description}>
          {slot.description ?? "No description recorded for this item."}
        </p>
      </div>
    </div>
  )
}