"use client"

import { Button } from "@/components/ui/button"
import { Input } from "@/components/ui/input"
import { Label } from "@/components/ui/label"
import { FormEvent, useState } from "react"
import { ScrollText, Sparkles, UserRound } from "lucide-react"
import styles from "./styles/CreateNewPlayer.module.css"

interface Player {
  id: number
  name: string
  secondName: string
}

interface CreateNewPlayerProps {
  onCreated?: (player: Player) => void
}

export default function CreateNewPlayer({ onCreated }: CreateNewPlayerProps) {
  const [name, setName] = useState("")
  const [secondName, setSecondName] = useState("")
  const [isSubmitting, setIsSubmitting] = useState(false)
  const [message, setMessage] = useState<string | null>(null)

  const handleSubmit = async (e: FormEvent<HTMLFormElement>) => {
    e.preventDefault()
    setMessage(null)

    if (!name.trim() || !secondName.trim()) {
      setMessage("Podaj imie i nazwisko bohatera.")
      return
    }

    setIsSubmitting(true)

    try {
      // Mock API call
      await new Promise((resolve) => setTimeout(resolve, 600))

      const newPlayer: Player = {
        id: Math.floor(Math.random() * 100000),
        name: name.trim(),
        secondName: secondName.trim(),
      }

      console.log("Mock created player:", newPlayer)

      setMessage(`Bohater "${newPlayer.name} ${newPlayer.secondName}" stworzony!`)
      setName("")
      setSecondName("")

      onCreated?.(newPlayer)
    } catch (err) {
      setMessage("Cos poszlo nie tak. Sprobuj ponownie.")
    } finally {
      setIsSubmitting(false)
    }
  }

  return (
    <div className={styles.panel}>
      <form
        className={styles.form}
        onSubmit={handleSubmit}
      >
        <div className={styles.header}>
          <div className={styles.headerIcon}>
            <UserRound className={styles.headerIconGlyph} />
          </div>
          <div className={styles.headerInfo}>
            <h2 className={styles.title}>Stworz Bohatera</h2>
            <p className={styles.subtitle}>Rejestr nowego bohatera w krainie</p>
          </div>
        </div>

        <div className={styles.fields}>
          <div className={styles.field}>
            <Label
              htmlFor='name'
              className={styles.label}
            >
              Imie
            </Label>
            <Input
              id='name'
              type='text'
              className={styles.input}
              value={name}
              onChange={(e) => setName(e.target.value)}
              placeholder='np. Jan'
              disabled={isSubmitting}
              autoComplete='off'
            />
          </div>

          <div className={styles.field}>
            <Label
              htmlFor='secondName'
              className={styles.label}
            >
              Nazwisko
            </Label>
            <Input
              id='secondName'
              type='text'
              className={styles.input}
              value={secondName}
              onChange={(e) => setSecondName(e.target.value)}
              placeholder='np. Kowalski'
              disabled={isSubmitting}
              autoComplete='off'
            />
          </div>
        </div>

        <Button
          type='submit'
          className={styles.button}
          disabled={isSubmitting}
        >
          <Sparkles className={styles.buttonIcon} />
          {isSubmitting ? "Tworzenie..." : "Stworz Bohatera"}
        </Button>

        {message && (
          <p className={styles.message}>
            <ScrollText className={styles.messageIcon} />
            {message}
          </p>
        )}
      </form>
    </div>
  )
}