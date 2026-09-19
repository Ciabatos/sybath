"use client"

import { SignInForm } from "@/components/login/SignInForm"
import { SignUpForm } from "@/components/login/SignUpForm"

type TUpgradeAccountForm = {
  description?: string
}

export function UpgradeAccountForm({ description }: TUpgradeAccountForm) {
  return (
    <>
      <p>{description}</p>
      <SignInForm />
      <SignUpForm />
    </>
  )
}
