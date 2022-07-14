using HemiPhoto
using Test, Images

@testset "HemiPhoto.jl" begin
	## load the image
	file = "./Mt_Gowler_Hemi.jpg"

	## test the zenith array
	img = Images.load(file)
	@test (round(HemiPhoto.HemiLAI.getZenithArray(img)[1,1], digits=2) == 2.83)

	# ## test the LAI
	# thresholdImage = HemiPhoto.Thresholds.histogramThreshold(img, "Moments")
	# nrings = 9
	# LaiObj = HemiLAI.getLAI(thresholdImage, zenithArray, nrings)

	# @test (round(LaiObj.LAI, digits=2) == 0.44)

end
