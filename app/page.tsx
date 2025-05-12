import SignUp from "@/components/SignUp"
import { Button } from "@/components/ui/button"
import Link from "next/link"
import styles from "./page.module.css"

export default async function HomePage() {
  return (
    <div className={styles.main}>
      <Button>
        <Link href={"/api/auth/signin"}>SignIn</Link>
      </Button>
      <Button>
        <Link href={"/api/auth/signout"}>SignOut</Link>
      </Button>
      <SignUp />
      <Link href="/map">Map</Link>
    </div>
  )
}
