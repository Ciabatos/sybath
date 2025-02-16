import styles from "./page.module.css"
import TestClient from "@/components/TestClient"
import SignIn from "@/components/SignIn"
import SignUp from "@/components/SignUp"
import { auth } from "@/auth"

export default async function HomePage() {
  const session = await auth()
  console.log(session, "Server session")
  return (
    <div className={styles.main}>
      <SignIn />
      <SignUp />
      <TestClient />
    </div>
  )
}
