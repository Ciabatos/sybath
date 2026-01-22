"use client"
import createImage from "@/methods/functions/util/createImage"

export function createHeroPortrait() {
  function createPortrait(imageUrl: string | undefined) {
    return createImage(imageUrl, "heroPortrait")
  }

  return {
    createPortrait,
  }
}
