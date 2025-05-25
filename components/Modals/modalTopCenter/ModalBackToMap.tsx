"use client"
import styles from "@/components/modals/modalTopCenter/styles/ModalBackToMap.module.css"
import { Button } from "@/components/ui/button"
import { ArrowLeft } from "lucide-react"
import Link from "next/link"
export default function ModalBackToMap() {
  return (
    <div className={styles.container}>
      <Link href="/map">
        <Button size={"lg"}>
          <ArrowLeft className="mr-2 h-4 w-4" />
          Back to Map
        </Button>
      </Link>
    </div>
  )
}
