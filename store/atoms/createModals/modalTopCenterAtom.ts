import { EPanelsTopCenter } from "@/types/enumeration/EPanelsTopCenter"
import { atom } from "jotai"

export const modalTopCenterAtom = atom<EPanelsTopCenter>(EPanelsTopCenter.Inactive)
