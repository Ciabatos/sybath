import styles from "./page.module.css"
import Map from "@/components/Map"
import MapTiles from "@/components/MapTiles"
import { auth } from "@/auth"

export default async function MapPage() {
  const session = await auth()
  console.log(session, "Server session")

  return (
    <div className={styles.main}>
      <Map>
        <MapTiles />
      </Map>
    </div>
  )
}
