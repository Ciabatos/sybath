"use client"

import { useState } from "react"

import styles from "./styles/CreatePlayerPanelStats.module.css"
import { Badge } from "@/components/ui/badge"
import { Field, FieldDescription, FieldLabel } from "@/components/ui/field"
import { Progress } from "@/components/ui/progress"
import { Slider } from "@/components/ui/slider"

const mockAttributes = [
  { key: "sila", label: "Siła", hint: "Obrażenia w walce wręcz" },
  { key: "zwinnosc", label: "Zręczność", hint: "Atak dystansowy i uniki" },
  { key: "inteligencja", label: "Inteligencja", hint: "Magia i wiedza" },
  { key: "witalnosc", label: "Witalność", hint: "Punkty życia" },
  { key: "charyzma", label: "Charyzma", hint: "Wpływ i rozmowy" },
] as const

type AttributeKey = (typeof mockAttributes)[number]["key"]

type AttributeState = Record<AttributeKey, number>

const mockInitial: AttributeState = {
  sila: 14,
  zwinnosc: 12,
  inteligencja: 8,
  witalnosc: 13,
  charyzma: 10,
}

export default function CreatePlayerPanelStats() {
  const [level, setLevel] = useState(1)
  const [attributes, setAttributes] = useState<AttributeState>(mockInitial)

  function updateAttribute(key: AttributeKey, value: number[]) {
    setAttributes((prev) => ({ ...prev, [key]: value[0] }))
  }

  const hp = 20 + attributes.witalnosc * 4 + level * 2
  const mp = 10 + attributes.inteligencja * 3
  const actionPoints = 6 + Math.floor(attributes.zwinnosc / 5)
  const maxStat = 20
  const budget = 27

  const meters = [
    { id: "hp", label: "Punkty życia", value: hp, max: 200 },
    { id: "mp", label: "Punkty many", value: mp, max: 100 },
    { id: "ap", label: "Punkty akcji", value: actionPoints, max: 10 },
  ]

  return (
    <div className={styles.layout}>
      <section className={styles.card}>
        <div className={styles.cardHeader}>
          <h3 className={styles.title}>Atrybuty</h3>
          <p className={styles.description}>
            Zmień wartości suwakami — punkt startowy: 27.
          </p>
        </div>

        <div className={styles.levelRow}>
          <FieldLabel className={styles.levelLabel}>Poziom przyjścia</FieldLabel>
          <Badge variant="secondary" className={styles.levelBadge}>
            {level}
          </Badge>
          <Slider
            min={1}
            max={20}
            step={1}
            value={[level]}
            onValueChange={(value) => setLevel(value[0])}
            aria-label="Poziom przyjścia"
            className={styles.levelSlider}
          />
        </div>

        <div className={styles.statsList}>
          {mockAttributes.map((attribute) => (
            <div key={attribute.key} className={styles.statRow}>
              <div className={styles.statHead}>
                <FieldLabel>{attribute.label}</FieldLabel>
                <span className={styles.statValue}>
                  {attributes[attribute.key]}
                </span>
              </div>
              <Field>
                <Slider
                  min={0}
                  max={maxStat}
                  step={1}
                  value={[attributes[attribute.key]]}
                  onValueChange={(value) =>
                    updateAttribute(attribute.key, value)
                  }
                  aria-label={attribute.label}
                />
                <FieldDescription>{attribute.hint}</FieldDescription>
              </Field>
            </div>
          ))}
        </div>
      </section>

      <section className={styles.card}>
        <div className={styles.cardHeader}>
          <h3 className={styles.title}>Podsumowanie</h3>
          <p className={styles.description}>
            Wartości wyliczone automatycznie na podstawie atrybutów.
          </p>
        </div>

        <div className={styles.meters}>
          {meters.map((meter) => (
            <div key={meter.id} className={styles.meter}>
              <div className={styles.meterHead}>
                <span className={styles.meterLabel}>{meter.label}</span>
                <span className={styles.meterValue}>{meter.value}</span>
              </div>
              <Progress
                value={Math.min(100, (meter.value / meter.max) * 100)}
              />
            </div>
          ))}
        </div>

        <dl className={styles.summary}>
          <div className={styles.summaryRow}>
            <dt>Wydano punktów</dt>
            <dd>
              {Object.values(attributes).reduce((a, b) => a + b, 0)} /{" "}
              {budget + (level - 1) * 3}
            </dd>
          </div>
          <div className={styles.summaryRow}>
            <dt>Bonus do ataku</dt>
            <dd>+{Math.floor(attributes.sila * 1.5)}</dd>
          </div>
          <div className={styles.summaryRow}>
            <dt>Obrażenia krytyczne</dt>
            <dd>{5 + attributes.zwinnosc}%</dd>
          </div>
          <div className={styles.summaryRow}>
            <dt>Trudność</dt>
            <dd>{level <= 2 ? "Łatwa" : level <= 6 ? "Średnia" : "Trudna"}</dd>
          </div>
        </dl>
      </section>
    </div>
  )
}
