"use server"

import MainMenuBackToButton from "@/components/login/MainMenuBackToButton"
import { SignOutButton } from "@/components/login/SignOutButton"
import { SignUpForm } from "@/components/login/SignUpForm"
import { auth } from "@/lib/auth"
import { headers } from "next/headers"

export default async function SignUp() {
  const session = await auth.api.getSession({ headers: await headers() })

  if (session) return <SignOutButton />

  return (
    <>
      <SignUpForm />
      <MainMenuBackToButton />
    </>
  )
}
