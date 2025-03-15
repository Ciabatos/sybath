export const combineImages = (...images: (string | null)[]): string => {
  return images.filter(Boolean).join(", ")
}
