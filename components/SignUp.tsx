"use client"
import { signUpAction } from "@/methods/actions/signUpAction"
import { useActionState } from "react"

export default function SignUp() {
  const [state, formAction] = useActionState(signUpAction, null)
  return (
    <div className="bg-red mx-auto max-w-md rounded-lg p-6 shadow-md">
      <h2 className="mb-4 text-2xl font-bold">Sign Up</h2>
      <form
        action={formAction}
        className="space-y-4">
        <input
          type="email"
          name="email"
          placeholder="Email"
          required
          className="w-full rounded border p-2"
        />
        <input
          type="password"
          name="password"
          placeholder="Password"
          required
          className="w-full rounded border p-2"
        />
        <button
          type="submit"
          className="w-full rounded bg-blue-500 py-2 text-white transition hover:bg-blue-600">
          Sign Up
        </button>
      </form>
      {state !== null && state !== undefined ? <div>{state}</div> : null}
    </div>
  )
}
