"use client"
import { Button } from "@/components/ui/button"
import { useMapId } from "@/methods/hooks/world/composite/useMapId"
import { ArrowLeft } from "lucide-react"
import Link from "next/link"
import styles from "./styles/PanelBackToMap.module.css"

type TParams = {
  closePanel: () => void
}

export default function PanelBackToMap({ closePanel }: TParams) {
  const { mapId } = useMapId()

  return (
    <div className={styles.container}>
      <Link href={`/map/${mapId}`}>
        <Button
          onClick={closePanel}
          size={"lg"}
        >
          <ArrowLeft className='mr-2 h-4 w-4' />
          Back to Map
        </Button>
      </Link>
    </div>
  )
}
