"use client"

import { useState } from "react"

import styles from "./styles/CreatePlayerPanelAppearance.module.css"
import { Avatar, AvatarFallback } from "@/components/ui/avatar"
import { FieldLabel } from "@/components/ui/field"
import { Switch } from "@/components/ui/switch"

const mockPalettes = [
  { id: "zloty", name: "Złoty Rycerz", primary: "#c89a4a", secondary: "#5c3a28" },
  { id: "leśny", name: "Strażnik Lasu", primary: "#5f8d52", secondary: "#2f4a2b" },
  { id: "lodowy", name: "Lodowy Arcymag", primary: "#6fa8c7", secondary: "#2b4a63" },
  { id: "karmazyn", name: "Karmazynowa Wdowa", primary: "#a23830", secondary: "#4a1f1c" },
  { id: "fiolet", name: "Archanista", primary: "#8a63c7", secondary: "#3d2a63" },
  { id: "obsydian", name: "Obsydian", primary: "#4a4a52", secondary: "#1f1f24" },
]

const mockFrames = [
  { id: "okragly", name: "Okrągła" },
  { id: "kwadratowy", name: "Kwadratowa" },
  { id: "pasmowy", name: "Pasmowa" },
]

const mockExtras = [
  {
    id: "hełm",
    name: "Hełm",
    hint: "Ukrywa włosy, dodaje +2 do obrony",
  },
  {
    id: "broń",
    name: "Broń w ręku",
    hint: "Widoczna w podglądzie portretu",
  },
  {
    id: "tarcza",
    name: "Tarcza",
    hint: "Tylko dla postaci walczących wręcz",
  },
  {
    id: "peleryna",
    name: "Peleryna",
    hint: "Wpływa na sylwetkę na portrecie",
  },
]

export default function CreatePlayerPanelAppearance() {
  const [paletteId, setPaletteId] = useState(mockPalettes[0].id)
  const [frameId, setFrameId] = useState(mockFrames[0].id)
  const [extras, setExtras] = useState<string[]>(["hełm", "broń"])

  const palette =
    mockPalettes.find((item) => item.id === paletteId) ?? mockPalettes[0]

  function toggleExtra(id: string, checked: boolean) {
    setExtras((prev) =>
      checked ? [...prev, id] : prev.filter((item) => item !== id),
    )
  }

  return (
    <div className={styles.layout}>
      <section className={`${styles.card} ${styles.previewCard}`}>
        <div className={styles.cardHeader}>
          <h3 className={styles.title}>Podgląd</h3>
          <p className={styles.description}>Podgląd portretu w czasie rzeczywistym.</p>
        </div>

        <div
          className={`${styles.preview} ${styles[`frame${frameId}`]}`}
          style={{
            background: `linear-gradient(140deg, ${palette.primary}33 0%, ${palette.secondary}33 100%)`,
            borderColor: palette.primary,
          }}
        >
          <Avatar className={styles.previewAvatar}>
            <AvatarFallback
              className={styles.previewFallback}
              style={{ color: palette.primary }}
            >
              GR
            </AvatarFallback>
          </Avatar>

          <div className={styles.previewText}>
            <span className={styles.previewName}>Gorm Ironhand</span>
            <span className={styles.previewMeta}>{palette.name}</span>
          </div>
        </div>

        <div className={styles.extraList}>
          {mockExtras.map((extra) => (
            <div key={extra.id} className={styles.extraRow}>
              <div className={styles.extraText}>
                <FieldLabel>{extra.name}</FieldLabel>
                <span className={styles.extraHint}>{extra.hint}</span>
              </div>
              <Switch
                checked={extras.includes(extra.id)}
                onCheckedChange={(checked) => toggleExtra(extra.id, checked)}
                aria-label={extra.name}
              />
            </div>
          ))}
        </div>
      </section>

      <section className={styles.card}>
        <div className={styles.cardHeader}>
          <h3 className={styles.title}>Paleta</h3>
          <p className={styles.description}>
            Kolory portretu i wyróżnienia w interfejsie.
          </p>
        </div>

        <div className={styles.swatchGrid}>
          {mockPalettes.map((item) => (
            <button
              type="button"
              key={item.id}
              onClick={() => setPaletteId(item.id)}
              className={`${styles.swatch} ${
                item.id === paletteId ? styles.swatchActive : ""
              }`}
            >
              <span
                className={styles.swatchColor}
                style={{ background: item.primary }}
              />
              <span
                className={styles.swatchColor}
                style={{ background: item.secondary }}
              />
              <span className={styles.swatchLabel}>{item.name}</span>
            </button>
          ))}
        </div>

        <div className={styles.cardHeader}>
          <h3 className={styles.title}>Ramka portretu</h3>
        </div>

        <div className={styles.frameList}>
          {mockFrames.map((frame) => (
            <button
              type="button"
              key={frame.id}
              onClick={() => setFrameId(frame.id)}
              className={`${styles.frameButton} ${
                frame.id === frameId ? styles.frameButtonActive : ""
              }`}
            >
              {frame.name}
            </button>
          ))}
        </div>
      </section>
    </div>
  )
}
