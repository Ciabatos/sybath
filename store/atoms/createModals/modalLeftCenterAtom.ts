import { EPanelsLeftCenter } from "@/types/enumeration/EPanelsLeftCenter"
import { atom } from "jotai"

export const modalLeftCenterAtom = atom<EPanelsLeftCenter>(EPanelsLeftCenter.Inactive)
