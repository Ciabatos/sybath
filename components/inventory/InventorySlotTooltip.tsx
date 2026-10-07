"use client"

import { Tooltip, TooltipContent, TooltipTrigger } from "@/components/ui/tooltip"
import { ReactNode } from "react"
import styles from "./styles/InventorySlotTooltip.module.css"

export type TSlotMeta = {
  label: string
  value: string
}

type TProps = {
  /** Nazwa przedmiotu albo podpis slotu, gdy slot jest pusty. */
  title: string
  description?: string
  /** Ikona przedmiotu (albo ikona typu slotu dla pustych slotów gearowych). */
  icon?: ReactNode
  meta?: TSlotMeta[]
  empty?: boolean
  /**
   * Kontrolowane otwarcie. `undefined` = tooltip sterowany przez Radix (hover/touch).
   * `false` wymusza zamknięcie, np. w trakcie przeciągania przedmiotu.
   */
  open?: boolean
  children: ReactNode
}

/**
 * Opis przedmiotu po najechaniu myszką lub dotknięciu (mobile).
 * Radix Tooltip reaguje na `pointerdown` dla `touch`, więc ten sam komponent
 * obsługuje oba wejścia bez dodatkowej obsługi zdarzeń.
 */
export function InventorySlotTooltip({
  title,
  description,
  icon,
  meta,
  empty,
  open,
  children,
}: TProps) {
  return (
    <Tooltip
      open={open}
    >
      <TooltipTrigger asChild>{children}</TooltipTrigger>
      <TooltipContent
        side='top'
        sideOffset={8}
        className={styles.tooltip}
      >
        <div className={styles.tooltipHeader}>
          {icon && <span className={styles.tooltipIcon}>{icon}</span>}
          <span className={styles.tooltipTitle}>{title}</span>
        </div>

        {empty ? (
          <p className={styles.tooltipEmpty}>Empty slot</p>
        ) : (
          description && <p className={styles.tooltipDescription}>{description}</p>
        )}

        {meta && meta.length > 0 && (
          <dl className={styles.tooltipMeta}>
            {meta.map((entry) => (
              <div
                key={entry.label}
                className={styles.tooltipMetaItem}
              >
                <dt>{entry.label}</dt>
                <dd>{entry.value}</dd>
              </div>
            ))}
          </dl>
        )}
      </TooltipContent>
    </Tooltip>
  )
}