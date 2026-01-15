import { ReactNode } from "react"
import { SWRConfig } from "swr"

type SWRHydratorProps = {
  fallback: Record<string, any>
  children: ReactNode
}

/**
 * SWRHydrator wstrzykuje dane fallback do kontekstu SWR
 * dla dzieci.
 */
export function SWRHydrator({ fallback, children }: SWRHydratorProps) {
  return <SWRConfig value={{ fallback }}>{children}</SWRConfig>
}
