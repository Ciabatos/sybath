"use client"

import { useInventoryMonitor } from "@/methods/hooks/inventory/composite/useInventoryMonitor"

const modals = import.meta.glob("@/components/modals/*.tsx", {
  eager: true,
})

export default function ModalHandling() {
  useInventoryMonitor()

  return (
    <>
      {Object.entries(modals)
        .filter(([path]) => !path.endsWith("ModalHandling.tsx"))
        .map(([path, module]: any) => {
          const Component = module.default

          return <Component key={path} />
        })}
    </>
  )
}
