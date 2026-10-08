"use client"

import { Switch } from "@/components/ui/switch"
import { activeLayerAtom } from "@/store/atoms"
// `MAP_LAYERS` i `TMapLayer` nie trafiają do barrelu — `store/generateAtomsHandling.js`
// wyłapuje tylko `export const (\w+)Atom`. Stąd import z głębokiej ścieżki.
import { MAP_LAYERS, TMapLayer } from "@/store/atoms/client/activeLayerAtom"
import { useAtom } from "jotai"
import { Eye, Package, Users, X } from "lucide-react"
import { useState } from "react"
import styles from "./styles/MapLayersPanel.module.css"

type TRow = {
  value: TMapLayer
  label: string
  hint: string
  icon: typeof Eye
}

const ROWS: TRow[] = [
  {
    value: MAP_LAYERS.resources,
    label: "Resources",
    hint: "Icon per resource",
    icon: Package,
  },
  {
    value: MAP_LAYERS.heroes,
    label: "Heroes",
    hint: "Marker per hero",
    icon: Users,
  },
]

/**
 * Panel warstw mapy.
 *
 * Zwykły element nakładany na mapę, NIE panel modala — nie ma tu
 * `useModal*`, nie ma wpisu w `panelBottomCenter`. Renderuje go `MapWrapper`
 * obok `TransformWrapper`, więc nie skaluje się i nie przesuwa razem z mapą.
 *
 * Sam trzyma stan rozwinięcia. Wybór warstwy jest wyłączny i żyje w
 * `activeLayerAtom`.
 */
export default function MapLayersPanel() {
  const [isOpen, setIsOpen] = useState(false)
  const [activeLayer, setActiveLayer] = useAtom(activeLayerAtom)

  function toggleLayer(value: TMapLayer) {
    // Kliknięcie aktywnej warstwy wraca do bazy.
    const layer = activeLayer.layer === value ? MAP_LAYERS.none : value
    setActiveLayer({ layer })
  }

  const hasLayer = activeLayer.layer !== MAP_LAYERS.none

  return (
    <div className={styles.overlay}>
      {isOpen && (
        <div className={styles.panel}>
          <header className={styles.header}>
            <span className={styles.headerEmblem}>
              <Eye className={styles.headerEmblemIcon} />
            </span>

            <div className={styles.headerInfo}>
              <h2 className={styles.title}>Map Layers</h2>
              <p className={styles.subtitle}>Base map is always shown</p>
            </div>

            <button
              type="button"
              onClick={() => setIsOpen(false)}
              className={styles.closeButton}
              aria-label="Close map layers"
            >
              <X className={styles.closeIcon} />
            </button>
          </header>

          <div className={styles.rows}>
            {ROWS.map(({ value, label, hint, icon: Icon }) => {
              const checked = activeLayer.layer === value

              return (
                <div key={value} className={styles.row} data-checked={checked}>
                  <button
                    type="button"
                    onClick={() => toggleLayer(value)}
                    className={styles.rowButton}
                    aria-pressed={checked}
                  >
                    <span className={styles.rowIcon}>
                      <Icon className={styles.rowIconGlyph} />
                    </span>

                    <span className={styles.rowInfo}>
                      <span className={styles.rowLabel}>{label}</span>
                      <span className={styles.rowHint}>{hint}</span>
                    </span>
                  </button>

                  <Switch
                    checked={checked}
                    onCheckedChange={() => toggleLayer(value)}
                    aria-label={label}
                    className={styles.switch}
                  />
                </div>
              )
            })}
          </div>
        </div>
      )}

      <button
        type="button"
        onClick={() => setIsOpen(!isOpen)}
        className={styles.toggle}
        data-open={isOpen}
        aria-label="Map layers"
        aria-expanded={isOpen}
        title="Map layers"
      >
        <Eye className={styles.toggleIcon} />
        {hasLayer && <span className={styles.toggleDot} />}
      </button>
    </div>
  )
}