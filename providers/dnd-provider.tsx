"use client"

import { useInventoryMonitor } from "@/methods/hooks/inventory/composite/useInventoryMonitor"
import { DragDropProvider } from "@dnd-kit/react"
import { ReactNode } from "react"

export function DndProvider({ children }: { children: ReactNode }) {
  return (
    <DragDropProvider>
      <InventoryMonitorWrapper>{children}</InventoryMonitorWrapper>
    </DragDropProvider>
  )
}

function InventoryMonitorWrapper({ children }: { children: ReactNode }) {
  useInventoryMonitor()
  return <>{children}</>
}
