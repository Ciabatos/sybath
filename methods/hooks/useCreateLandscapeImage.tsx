"use client"

import Image from "next/image"

export function useCreateLandscapeImage(imageUrl: string | undefined) {
  const baseUrl = process.env.NEXT_PUBLIC_BASE_URL

  if (!imageUrl) {
    return ""
  }

  const imageSrc = `/landscapeTypePicture/${imageUrl}`

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
