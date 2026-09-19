"use client"
import { authClient } from "@/lib/auth-client"
import { useState } from "react"

export function SignUpForm() {
  const [email, setEmail] = useState("")
  const [password, setPassword] = useState("")
  const [name, setName] = useState("")
  const [error, setError] = useState<string | null>(null)

  async function handleSubmit(e: React.FormEvent) {
    e.preventDefault()
    setError(null)

    const { error } = await authClient.signUp.email({
      email,
      password,
      name,
      callbackURL: "/", // gdzie przekierować po rejestracji
    })

    if (error) setError(error.message ?? "Wystąpił błąd")
  }

  return (
    <form onSubmit={handleSubmit}>
      <input placeholder="Imię" value={name} onChange={(e) => setName(e.target.value)} />
      <input type="email" placeholder="Email" value={email} onChange={(e) => setEmail(e.target.value)} />
      <input type="password" placeholder="Hasło" value={password} onChange={(e) => setPassword(e.target.value)} />
      {error && <p style={{ color: "red" }}>{error}</p>}
      <button type="submit">Zarejestruj się</button>
    </form>
  )
}