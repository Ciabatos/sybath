"use client"
import { authClient } from "@/lib/auth-client"
import { useRouter } from "next/navigation"
import { useState } from "react"

export function SignOutButton() {
  const router = useRouter()
  const [loading, setLoading] = useState(false)

  async function handleSignOut() {
    setLoading(true)
    await authClient.signOut({
      fetchOptions: {
        onSuccess: () => {
          router.push("/")
          router.refresh()
        },
      },
    })
    setLoading(false)
  }

  return (
    <div>
      <button
        onClick={handleSignOut}
        disabled={loading}
      >
        {loading ? `Wylogowuję...` : "Wyloguj się"}
      </button>
    </div>
  )
}
