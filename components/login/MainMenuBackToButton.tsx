"use client"
import { useRouter } from "next/navigation"

export default function MainMenuBackToButton() {
  const router = useRouter()

  const handleClick = () => {
    router.push(`/`)
  }

  return (
    <button onClick={() => handleClick()}>
      <div>Back to main menu</div>
    </button>
  )
}
