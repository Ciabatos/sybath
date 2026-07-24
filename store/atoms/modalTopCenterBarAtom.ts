import { EPanelsTopCenterBar } from "@/types/enumeration/EPanelsTopCenterBar"
import { atom } from "jotai"

export const modalTopCenterBarAtom = atom<EPanelsTopCenterBar>(EPanelsTopCenterBar.Inactive)
