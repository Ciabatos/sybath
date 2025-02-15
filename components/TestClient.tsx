"use client"

import useSWR from "swr"
import { useSession } from "next-auth/react"
import Link from "next/link"

export default function TestClient() {
  const session = useSession()
  console.log(session, "Client session")
  const { data, error, isLoading } = useSWR("/api/users")
  if (!session.data?.user?.email) {
    return <div>Sing In !</div>
  }
  if (isLoading) {
    return <div>Loading...</div>
  }

  if (error) {
    return <div>Error: {error.message}</div>
  }

  return (
    <div>
      <p>Data from users, first row: {data[0].email}</p>
      <p>Session: {session?.data?.user?.email}</p>
      <p>Session: {session?.data?.user?.name}</p>
      <Link href="/map">Map</Link>
    </div>
  )
}
