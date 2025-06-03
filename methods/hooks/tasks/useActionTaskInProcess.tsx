import { useFetchActionTaskInProcess } from "@/methods/hooks/tasks/useFetchActionTaskInProcess"
import { useMutateActionTaskInProcess } from "@/methods/hooks/tasks/useMutateActionTaskInProcess"
import { actionTaskInProcessAtom } from "@/store/atoms"
import { useAtomValue } from "jotai"

export function useActionTaskInProcess() {
  useFetchActionTaskInProcess()
  const actionTaskInProcess = useAtomValue(actionTaskInProcessAtom)
  const { mutateActionTaskInProcess } = useMutateActionTaskInProcess()

  return { actionTaskInProcess, mutateActionTaskInProcess }
}
