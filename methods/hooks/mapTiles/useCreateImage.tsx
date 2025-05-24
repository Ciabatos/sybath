"use client"
import Image from "next/image"

export function useCreateImage() {
  function createImageFromUrl(imageUrl: string | undefined, type: string) {
    const baseUrl = process.env.NEXT_PUBLIC_BASE_URL
    if (!imageUrl) {
      return ""
    }
    const imageSrc = `/${type}/${imageUrl}`
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

  function createPlayerImage(imageUrl: string | undefined) {
    return createImageFromUrl(imageUrl, "playersPicture")
  }

  function createLandscapeImage(imageUrl: string | undefined) {
    return createImageFromUrl(imageUrl, "landscapeTypePicture")
  }

  function createBackgroundImage(imageUrl: string | undefined) {
    return createImageFromUrl(imageUrl, "terrainTypePicture")
  }

  function createCitiesImage(imageUrl: string | undefined) {
    return createImageFromUrl(imageUrl, "citiesPicture")
  }

  function creatDistrictsImage(imageUrl: string | undefined) {
    return createImageFromUrl(imageUrl, "districstPicture")
  }

  function creatBuildingsImage(imageUrl: string | undefined) {
    return createImageFromUrl(imageUrl, "buildingsPicture")
  }
  const combineImages = (...images: string[]): string => {
    return images.filter(Boolean).join(", ")
  }

  return { createPlayerImage, createLandscapeImage, createBackgroundImage, createCitiesImage, creatDistrictsImage, creatBuildingsImage, combineImages }
}
