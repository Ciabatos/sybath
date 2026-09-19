"use client";
import { authClient } from "@/lib/auth-client";
import { useState } from "react";

export function SignInForm() {
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [error, setError] = useState<string | null>(null);

  async function handleSubmit(e: React.FormEvent) {
    e.preventDefault();
    setError(null);

    const { error } = await authClient.signIn.email({
      email,
      password,
      callbackURL: "/",
    });

    if (error) setError(error.message ?? "Nieprawidłowy email lub hasło");
  }

  return (
    <form onSubmit={handleSubmit}>
      <input type="email" placeholder="Email" value={email} onChange={(e) => setEmail(e.target.value)} />
      <input type="password" placeholder="Hasło" value={password} onChange={(e) => setPassword(e.target.value)} />
      {error && <p style={{ color: "red" }}>{error}</p>}
      <button type="submit">Zaloguj się</button>
    </form>
  );
}