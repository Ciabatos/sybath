import { MapDataProvider } from "@/providers/MapDataProvider"

export default function MapLayout({
  children,
}: Readonly<{
  children: React.ReactNode
}>) {
  return (
    <MapDataProvider>
      <html lang="en">
        <body>{children}</body>
      </html>
    </MapDataProvider>
  )
}
