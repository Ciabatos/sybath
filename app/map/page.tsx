import styles from "./page.module.css"

import { auth } from "@/auth"
import MapTilesServer from "@/components/MapTilesServer"

export default async function MapPage() {
  const session = await auth()
  console.log(session, "Server session")

  return (
    <div className={styles.main}>
      <MapTilesServer />
    </div>
  )
}
