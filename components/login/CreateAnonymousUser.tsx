"use client"

import { CreateAnonymousUser } from "@/methods/server-fetchers/userId/composite/useCreateAnonymousUser"

export default function CreateAnonymousUserButton() {
  const handleClick = async () => {
    await CreateAnonymousUser()
  }

  return <button onClick={handleClick}>DEBUG: KONTO ANONIMOWE</button>
}
