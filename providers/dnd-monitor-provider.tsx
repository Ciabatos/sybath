"use client"

import { useInventoryMonitor } from "@/methods/hooks/inventory/composite/useInventoryMonitor"

export function DndMonitorProvider() {
  useInventoryMonitor()
  return null
}
