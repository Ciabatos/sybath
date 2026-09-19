"use server"

import MainMenuBackToButton from "@/components/login/MainMenuBackToButton"
import { SignInForm } from "@/components/login/SignInForm"
import { SignOutButton } from "@/components/login/SignOutButton"
import { auth } from "@/lib/auth"
import { headers } from "next/headers"

export default async function SignIn() {
  const session = await auth.api.getSession({ headers: await headers() })

  if (session) return <SignOutButton />

  return (
    <>
      <SignInForm />
      <MainMenuBackToButton />
    </>
  )
}
