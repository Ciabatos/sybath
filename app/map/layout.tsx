'use server'
//import { DataProvider } from "next-auth/react"



export default function MapLayout({
  children,
}: Readonly<{
  children: React.ReactNode
}>) {
  return (
      //<DataProvider>
        <html lang="en">
          <body>{children}</body>
        </html>
      //</DataProvider>
  )
}
