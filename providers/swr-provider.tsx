"use client"
import { SWRConfig } from "swr"

// eslint-disable-next-line @typescript-eslint/no-explicit-any
export const SWRProvider = ({ children, value }: { children: React.ReactNode; value: any }) => {
  return (
    <SWRConfig
      value={{
        fetcher: (url: string) => fetch(url).then((res) => res.json()),
        ...value,
      }}>
      {children}
    </SWRConfig>
  )
}
