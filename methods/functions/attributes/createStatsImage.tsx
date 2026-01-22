"use client"
import createImage from "@/methods/functions/util/createImage"

export function createBackgroundImage() {
  function createStatsImage(imageUrl: string | undefined) {
    return createImage(imageUrl, "statsPicture")
  }

  return {
    createStatsImage,
  }
}
