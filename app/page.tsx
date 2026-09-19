"use server"
import { SignInButton } from "@/components/login/SignInButton"
import { SignOutButton } from "@/components/login/SignOutButton"
import { SignUpButton } from "@/components/login/SignUpButton"
import { auth } from "@/lib/auth"
import { headers } from "next/headers"
import Link from "next/link"
import styles from "./page.module.css"

export default async function HomePage() {
  const session = await auth.api.getSession({ headers: await headers() })
  const sessionUserId = session?.user?.id

  if (!session) {
    return (
      <>
        <SignInButton />
        <SignUpButton />
      </>
    )
  }

  return (
    <div className={styles.main}>
      <div>PlayerId: {sessionUserId}</div>
      <SignOutButton />
      <Link href='/map/1'>Play !</Link>
    </div>
  )
}
