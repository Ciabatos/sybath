"use client"

import { useState } from "react"

import styles from "./styles/CreatePlayerPanelBasics.module.css"
import { Avatar, AvatarFallback } from "@/components/ui/avatar"
import { Badge } from "@/components/ui/badge"
import { Field, FieldDescription, FieldLabel } from "@/components/ui/field"
import { Input } from "@/components/ui/input"
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "@/components/ui/select"
import { Textarea } from "@/components/ui/textarea"

const mockClasses = [
  { id: "wojownik", name: "Wojownik", role: "Frontliner", hp: 140, mp: 40 },
  { id: "mag", name: "Mag", role: "Caster", hp: 80, mp: 160 },
  { id: "zlowodziej", name: "Złodziej", role: "Skrytobójca", hp: 95, mp: 60 },
  { id: "kaplan", name: "Kapłan", role: "Wspornik", hp: 110, mp: 130 },
]

const mockRaces = [
  "Człowiek",
  "Krasnolud",
  "Elf",
  "Krasnolud kopalniczy",
  "Półelf",
  "Tiefling",
]

const mockAlignments = [
  "Prawość",
  "Neutralny",
  "Chaos",
]

export default function CreatePlayerPanelBasics() {
  const [classId, setClassId] = useState(mockClasses[0].id)

  const activeClass =
    mockClasses.find((item) => item.id === classId) ?? mockClasses[0]

  return (
    <div className={styles.layout}>
      <section className={styles.card}>
        <div className={styles.cardHeader}>
          <h3 className={styles.title}>Klasa postaci</h3>
          <p className={styles.description}>
            Klasa ustala statystyki bazowe orazbonus do obrażeń.
          </p>
        </div>

        <div className={styles.identity}>
          <Avatar className={styles.avatar}>
            <AvatarFallback className={styles.avatarFallback}>
              {activeClass.name.slice(0, 2).toUpperCase()}
            </AvatarFallback>
          </Avatar>
          <div className={styles.identityText}>
            <span className={styles.identityName}>{activeClass.name}</span>
            <Badge variant="secondary">{activeClass.role}</Badge>
          </div>
        </div>

        <div className={styles.classList}>
          {mockClasses.map((item) => (
            <button
              type="button"
              key={item.id}
              onClick={() => setClassId(item.id)}
              className={`${styles.classCard} ${
                item.id === classId ? styles.classCardActive : ""
              }`}
            >
              <span className={styles.classCardName}>{item.name}</span>
              <span className={styles.classCardMeta}>
                HP {item.hp} · MP {item.mp}
              </span>
            </button>
          ))}
        </div>

        <div className={styles.badges}>
          <Badge variant="outline">Punkty startowe: 27</Badge>
          <Badge variant="outline">Złoto: 150</Badge>
          <Badge variant="outline">Wyposażenie: podstawowe</Badge>
        </div>
      </section>

      <section className={styles.card}>
        <div className={styles.cardHeader}>
          <h3 className={styles.title}>Dane postaci</h3>
          <p className={styles.description}>
            Imię, rasa i orientacja moralna — reszta jest opcjonalna.
          </p>
        </div>

        <div className={styles.fields}>
          <Field>
            <FieldLabel htmlFor="cp-imie">Imię i nazwisko</FieldLabel>
            <Input id="cp-imie" placeholder="np. Gorm Ironhand" />
            <FieldDescription>Widoczne w kartach postaci.</FieldDescription>
          </Field>

          <Field>
            <FieldLabel htmlFor="cp-nick">Przydomek</FieldLabel>
            <Input id="cp-nick" placeholder="np. Młot Północy" />
          </Field>

          <Field>
            <FieldLabel>Klasa</FieldLabel>
            <Select value={classId} onValueChange={setClassId}>
              <SelectTrigger>
                <SelectValue placeholder="Wybierz klasę" />
              </SelectTrigger>
              <SelectContent>
                {mockClasses.map((item) => (
                  <SelectItem key={item.id} value={item.id}>
                    {item.name}
                  </SelectItem>
                ))}
              </SelectContent>
            </Select>
          </Field>

          <Field>
            <FieldLabel>Rasa</FieldLabel>
            <Select defaultValue="Człowiek">
              <SelectTrigger>
                <SelectValue placeholder="Wybierz rasę" />
              </SelectTrigger>
              <SelectContent>
                {mockRaces.map((race) => (
                  <SelectItem key={race} value={race}>
                    {race}
                  </SelectItem>
                ))}
              </SelectContent>
            </Select>
          </Field>

          <Field>
            <FieldLabel htmlFor="cp-wiek">Wiek</FieldLabel>
            <Input id="cp-wiek" type="number" min={1} max={900} placeholder="27" />
          </Field>

          <Field>
            <FieldLabel>Orientacja</FieldLabel>
            <Select defaultValue="Neutralny">
              <SelectTrigger>
                <SelectValue placeholder="Wybierz orientację" />
              </SelectTrigger>
              <SelectContent>
                {mockAlignments.map((item) => (
                  <SelectItem key={item} value={item}>
                    {item}
                  </SelectItem>
                ))}
              </SelectContent>
            </Select>
          </Field>

          <Field className={styles.spanTwo}>
            <FieldLabel htmlFor="cp-opis">Opis postaci</FieldLabel>
            <Textarea
              id="cp-opis"
              rows={4}
              placeholder="Motywacja, wygląd, znane relacje..."
            />
          </Field>
        </div>
      </section>
    </div>
  )
}
