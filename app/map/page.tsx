import styles from "./page.module.css"
import TestClient from "@/components/TestClient"
import { auth } from "@/auth"

export default async function Map() {
  const session = await auth()
  console.log(session, "Server session")
  return (
    <div className={styles.main}>
      <TestClient />
    </div>
  )
}
