"use client"
import getImageUrl from "@/methods/functions/util/getImageUrl"
import getImageUrlCss from "@/methods/functions/util/getImageUrlCss"

export function createImage() {
  function createPlayerImage(imageUrl: string | undefined) {
    return getImageUrlCss(imageUrl, "playersPicture")
  }

  function createLandscapeImage(imageUrl: string | undefined) {
    return getImageUrlCss(imageUrl, "landscapeTypePicture")
  }

  function createTerrainImage(imageUrl: string | undefined) {
    return getImageUrlCss(imageUrl, "terrainTypePicture")
  }

  function createCitiesImage(imageUrl: string | undefined) {
    return getImageUrlCss(imageUrl, "citiesPicture")
  }

  function creatDistrictsImage(imageUrl: string | undefined) {
    return getImageUrlCss(imageUrl, "districstPicture")
  }

  function creatBuildingsImage(imageUrl: string | undefined) {
    return getImageUrlCss(imageUrl, "buildingsPicture")
  }

  function createPlayerPortrait(imageUrl: string | undefined) {
    return getImageUrl(imageUrl, "heroPortrait")
  }

  const combineImages = (...images: string[]): string => {
    return images.filter(Boolean).join(", ")
  }

  return {
    createPlayerImage,
    createLandscapeImage,
    createTerrainImage,
    createCitiesImage,
    creatDistrictsImage,
    creatBuildingsImage,
    combineImages,
    createPlayerPortrait,
  }
}
