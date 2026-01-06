"use client"

import { useResetModals } from "@/methods/hooks/modals/useResetModals"
import { usePathname } from "next/navigation"
import { useEffect } from "react"

export function useResetModalsOnRouteChange() {
  const pathname = usePathname()
  const { resetModals } = useResetModals()

  useEffect(() => {
    // resetModals()
  }, [pathname, resetModals])
}
