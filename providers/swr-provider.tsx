"use client"
import { SWRConfig } from "swr"

const storedEtagMap = new Map<string, string>()

async function fetchWithETag<T>(url: string): Promise<T | undefined> {
  const headers: Record<string, string> = {}
  const storedEtag = storedEtagMap.get(url)

  if (storedEtag) headers["If-None-Match"] = storedEtag

  const res = await fetch(url, { headers })

  if (res.status === 304) {
    return undefined
  }

  if (!res.ok && res.status !== 304) {
    throw new Error(`Fetch error: ${res.status}`)
  }

  const newEtag = res.headers.get("etag")
  if (newEtag) storedEtagMap.set(url, newEtag)

  return res.json() as Promise<T>
}

// eslint-disable-next-line @typescript-eslint/no-explicit-any
export const SWRProvider = ({ children, value }: { children: React.ReactNode; value: any }) => {
  return (
    <SWRConfig
      value={{
        fetcher: fetchWithETag,
        ...value,
      }}
    >
      {children}
    </SWRConfig>
  )
}
