import { auth } from "@/auth"
import SignIn from "@/components/SignIn"
import SignUp from "@/components/SignUp"
import Link from "next/link"
import styles from "./page.module.css"

export default async function HomePage() {
  const session = await auth()
  console.log(session, "Server session")
  return (
    <div className={styles.main}>
      <SignIn />
      <SignUp />
      <Link href="/map">Map</Link>
    </div>
  )
}
