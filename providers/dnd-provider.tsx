"use client"

import { DragDropProvider } from "@dnd-kit/react"
import { ReactNode } from "react"

export function DndProvider({ children }: { children: ReactNode }) {
  return <DragDropProvider>{children}</DragDropProvider>
}
