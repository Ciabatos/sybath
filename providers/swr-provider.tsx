"use client"
import { SWRConfig } from "swr"

const etagMap = new Map<string, string>()

const fetchWithETag = async (url: string) => {
  const headers: Record<string, string> = {}
  const etag = etagMap.get(url)

  if (etag) headers["If-None-Match"] = etag

  const res = await fetch(url, { headers })
  if (res.status === 304) throw new Error("304 Not Modified")

  const newEtag = res.headers.get("etag")
  if (newEtag) etagMap.set(url, newEtag)
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
