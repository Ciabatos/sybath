"use client"

import Link from "next/link"

export function SignInButton() {
  return (
    <button>
      <Link href='/sign-in'>Sign In</Link>
    </button>
  )
}
