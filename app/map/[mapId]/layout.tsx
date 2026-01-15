import Portal from "@/components/portals/Portal"

export default function MapLayout({
  children,
}: Readonly<{
  children: React.ReactNode
}>) {
  return (
    <div>
      <Portal />
      {children}
    </div>
  )
}
