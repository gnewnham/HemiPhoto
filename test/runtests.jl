using HemiPhoto
using Test, Images

@testset "HemiPhoto.jl" begin
	# load the image
	file = "./test/Mt_Gowler_Hemi.jpg"

	## test the zenith array
	img = Images.load(file)
	@test (round(HemiPhoto.HemiLAI.getZenithArray(img)[1,1], digits=2) == 2.83)

	## test the LAI
	thresholdImage = HemiPhoto.Thresholds.histogramThreshold(img, "Moments")
	zenithArray = HemiPhoto.HemiLAI.getZenithArray(img)
	nrings = 9
	LaiObj = HemiPhoto.HemiLAI.getLAI(thresholdImage, zenithArray, nrings)
	@test (round(LaiObj.LAI, digits=2) == 0.44f0)

end
