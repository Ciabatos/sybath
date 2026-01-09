"use client"
import Image from "next/image"

export function createHeroPortrait() {
  function createImageFromUrl(imageUrl: string | undefined, type: string) {
    const baseUrl = process.env.NEXT_PUBLIC_BASE_URL
    if (!imageUrl) {
      return ""
    }
    const imageSrc = `/${type}/${imageUrl}`
    const imageComponent = (
      <Image
        src={imageSrc}
        layout='fill'
        objectFit='contain'
        quality={100}
        alt={imageUrl || ""}
        priority
      />
    )
    const optimizedImageUrl = `${baseUrl}${imageComponent.props.src}`
    return optimizedImageUrl
  }

  function createPortrait(imageUrl: string | undefined) {
    return createImageFromUrl(imageUrl, "heroPortrait")
  }

  return {
    createPortrait,
  }
}
