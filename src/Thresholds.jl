module Thresholds

export valueThreshold, histogramThreshold
using ImageBinarization, Images
import ImageCore

function valueThreshold(img, threshold=0.5)
	hsvImg = Images.HSV.(img)
	hsvBands = ImageCore.channelview(hsvImg)
	valueBand = hsvBands[3,:,:]
	binaryImage = Gray.(valueBand .> threshold)
end

# https://juliaimages.org/ImageBinarization.jl/stable/

function histogramThreshold(img, algText="Otsu")

	algNames = ["Otsu","MinimumIntermodes","Intermodes","MinimumError",
			"Moments","UnimodalRosin","Entropy","Balanced","Yen"]
	index = findall(algText .== algNames)
	if length(index) != 1
		println("Error: no matching binarization algorith")
		println("Options are: Otsu, MinimumIntermodes, Intermodes, MinimumError")
		println("             Moments, UnimodalRosin, Entropy, Balanced, Yen")
	else
		algs = [Otsu(),MinimumIntermodes(),Intermodes(),MinimumError(),
				Moments(),UnimodalRosin(),Entropy(),Balanced(),Yen()]
		binaryImage = binarize(img, algs[only(index)])
	end
end

end