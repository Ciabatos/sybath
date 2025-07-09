"use client"
import { SWRConfig } from "swr"

const storedEtagMap = new Map<string, string>()

const fetchWithETag = async (url: string) => {
  const headers: Record<string, string> = {}
  const storedEtag = storedEtagMap.get(url)

  if (storedEtag) headers["If-None-Match"] = storedEtag

  const res = await fetch(url, { headers })
  if (res.status === 304) {
    // Zwróć poprzednie dane z cache SWR (SWR to obsłuży)
    return undefined
  }
  const newEtag = res.headers.get("etag")
  if (newEtag) storedEtagMap.set(url, newEtag)
  return res.json()
}

// eslint-disable-next-line @typescript-eslint/no-explicit-any
export const SWRProvider = ({ children, value }: { children: React.ReactNode; value: any }) => {
  return (
    <SWRConfig
      value={{
        fetcher: fetchWithETag,
        ...value,
      }}>
      {children}
    </SWRConfig>
  )
}
