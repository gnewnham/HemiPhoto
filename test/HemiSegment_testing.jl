
# Example usage of the HemiLAI object and functions
# using Glob, ImageSegmentation, Images, ImageView ,ImageCore
# using Plots
# using DataFrames, GLM
# using ImageBinarization

using Images, Plots
include("../src/Thresholds.jl")
include("../src/HemiLAI.jl")

## load the image
file = "./test/Mt_Gowler_Hemi.jpg"
img = Images.load(file)
p1 = Plots.plot(img, title=basename(file))

## make an image where each pixel is the zenith angle
zenithArray = HemiLAI.getZenithArray(img)
p2 = plot(Gray.(zenithArray), title="Zenith Array")

## add zentih rings to a figure, default nrings=9
HemiLAI.plotRings(img, p2)

## threshold the image using value from the HSV transform
# thresholdImage = Thresholds.valueThreshold(img, 0.4)
# lab = "Threshold Image: "*string(thresVal)
# p3 = plot(thresholdImage, title=lab)

## threshold using binarization
algos = ["Otsu", "MinimumIntermodes", "Intermodes", "MinimumError",
		"Moments", "UnimodalRosin", "Entropy", "Balanced", "Yen"]
algo=algos[5]
thresholdImage = Thresholds.histogramThreshold(img, algo)
lab = "Binarization: "*algo
p3 = plot(thresholdImage, title="Binarization: "*algo)

# generate the LAI model
LaiObj = HemiLAI.getLAI(thresholdImage, zenithArray, 9)
p4 = HemiLAI.plotLaiModel(LaiObj, lab)

## put all the images onto the one page
fig = plot(p1, p2, p3, p4, layout = (2, 2), legend = false, thickness_scaling = 0.6)
savefig(fig, "./test/HemiLAI_images.pdf")
