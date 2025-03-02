"use client"

import Image from "next/image"

export function useCreatePlayerImage(imageUrl: string | undefined) {
  const baseUrl = process.env.NEXT_PUBLIC_BASE_URL

  if (!imageUrl) {
    return ""
  }

  const imageSrc = `/playersPicture/default.png`
  const imageComponent = (
    <Image
      src={imageSrc}
      layout="fill"
      objectFit="contain"
      quality={100}
      alt={imageUrl || ""}
      priority
    />
  )

  const optimizedImageUrl = `url(${baseUrl}${imageComponent.props.src})`

  return optimizedImageUrl
}
