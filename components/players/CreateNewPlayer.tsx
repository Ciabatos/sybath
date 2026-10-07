"use client"

import { FormEvent, useState } from "react"
import styles from "./styles/CreateNewPlayer.module.css"

interface Player {
  id: number
  firstName: string
  lastName: string
}

interface CreateNewPlayerProps {
  onCreated?: (player: Player) => void
}

export default function CreateNewPlayer({ onCreated }: CreateNewPlayerProps) {
  const [firstName, setFirstName] = useState("")
  const [lastName, setLastName] = useState("")
  const [isSubmitting, setIsSubmitting] = useState(false)
  const [message, setMessage] = useState<string | null>(null)

  const handleSubmit = async (e: FormEvent<HTMLFormElement>) => {
    e.preventDefault()
    setMessage(null)

    if (!firstName.trim() || !lastName.trim()) {
      setMessage("Please fill in both fields.")
      return
    }

    setIsSubmitting(true)

    try {
      // Mock API call
      await new Promise((resolve) => setTimeout(resolve, 600))

      const newPlayer: Player = {
        id: Math.floor(Math.random() * 100000),
        firstName: firstName.trim(),
        lastName: lastName.trim(),
      }

      console.log("Mock created player:", newPlayer)

      setMessage(`Player "${newPlayer.firstName} ${newPlayer.lastName}" created!`)
      setFirstName("")
      setLastName("")

      onCreated?.(newPlayer)
    } catch (err) {
      setMessage("Something went wrong. Try again.")
    } finally {
      setIsSubmitting(false)
    }
  }

  return (
    <form
      className={styles.form}
      onSubmit={handleSubmit}
    >
      <h2 className={styles.title}>Create New Player</h2>

      <div className={styles.field}>
        <label
          htmlFor='firstName'
          className={styles.label}
        >
          First name
        </label>
        <input
          id='firstName'
          type='text'
          className={styles.input}
          value={firstName}
          onChange={(e) => setFirstName(e.target.value)}
          placeholder='e.g. John'
          disabled={isSubmitting}
        />
      </div>

      <div className={styles.field}>
        <label
          htmlFor='lastName'
          className={styles.label}
        >
          Last name
        </label>
        <input
          id='lastName'
          type='text'
          className={styles.input}
          value={lastName}
          onChange={(e) => setLastName(e.target.value)}
          placeholder='e.g. Doe'
          disabled={isSubmitting}
        />
      </div>

      <button
        type='submit'
        className={styles.button}
        disabled={isSubmitting}
      >
        {isSubmitting ? "Creating..." : "Create"}
      </button>

      {message && <p className={styles.message}>{message}</p>}
    </form>
  )
}
