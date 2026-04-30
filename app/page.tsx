"use server"
import { auth } from "@/auth"
import SignUp from "@/components/singUp/SignUp"
import { Button } from "@/components/ui/button"
import Link from "next/link"
import styles from "./page.module.css"

export default async function HomePage() {
  const session = await auth()
  const userId = session?.user?.userId

  return (
    <div className={styles.main}>
      <div>PlayerId: {userId}</div>
      <Button>
        <Link href={"/api/auth/signin"}>SignIn</Link>
      </Button>
      <Button>
        <Link href={"/api/auth/signout"}>SignOut</Link>
      </Button>
      <SignUp />
      <Link href='/map/1'>Map</Link>
    </div>
  )
}
