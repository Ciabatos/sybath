export async function fetchFresh<T>(url: string): Promise<T> {
  const res = await fetch(url, { headers: { ["x-force-fresh"]: "true" } })

  if (!res.ok) {
    throw new Error(`Fetch error: ${res.status}`)
  }

  return res.json() as Promise<T>
}
