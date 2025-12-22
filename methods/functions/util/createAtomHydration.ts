/* eslint-disable @typescript-eslint/no-explicit-any */
import * as Atoms from "@/store/atoms" // import wszystkich atomów
import { WritableAtom } from "jotai"

type TServerEntity<TData = unknown> = {
  byKey: TData
  atomName: string
}

export function createAtomHydration(...entities: TServerEntity[]): [WritableAtom<any, [any], void>, any][] {
  const atomValues: [WritableAtom<any, [any], void>, any][] = []

  for (const entity of entities) {
    const atomKey = `${entity.atomName}`
    // console.log("automatic hydration:", atomKey)
    // @ts-expect-error dynamiczny dostęp do atomów
    const atom = Atoms[atomKey] as WritableAtom<any, [any], void> | undefined

    if (atom) {
      atomValues.push([atom, entity.byKey])
    }
  }

  return atomValues
}
