"use client"
import createImageCss from "@/methods/functions/util/createImageCss"

export function createBackgroundImage() {
  function createPlayerImage(imageUrl: string | undefined) {
    return createImageCss(imageUrl, "playersPicture")
  }

  function createLandscapeImage(imageUrl: string | undefined) {
    return createImageCss(imageUrl, "landscapeTypePicture")
  }

  function createTerrainImage(imageUrl: string | undefined) {
    return createImageCss(imageUrl, "terrainTypePicture")
  }

  function createCitiesImage(imageUrl: string | undefined) {
    return createImageCss(imageUrl, "citiesPicture")
  }

  function creatDistrictsImage(imageUrl: string | undefined) {
    return createImageCss(imageUrl, "districstPicture")
  }

  function creatBuildingsImage(imageUrl: string | undefined) {
    return createImageCss(imageUrl, "buildingsPicture")
  }

  function createHeroPortrait(imageUrl: string | undefined) {
    return createImageCss(imageUrl, "heroPortrait")
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
    createHeroPortrait,
  }
}
