
module HemiLAI

export getZenithArray, plotRings, getPgapArray, getLAI, plotLaiModel
import Images, Plots, GLM , DataFrames

function getZenithArray(img)
	dims = size(img)
	x0 = dims[2] / 2.0
	y0 = dims[1] /2.0
	radiusPixels = minimum(Array([x0, y0]))
	xarray = repeat(range(1, dims[1]), 1, dims[2]) .- y0
	yarray = transpose(repeat(range(1, dims[2]), 1, dims[1])) .- x0
	radiusArray = sqrt.(xarray.^2 .+ yarray.^2) ./ radiusPixels
	xarray = 0
	yarray = 0
	radiusRadianArray = radiusArray .* π/2
end

function plotRings(img, fig, nrings=9)
	dims = size(img)
	x0 = dims[2] / 2.0
	y0 = dims[1] /2.0
	radiusPixels = minimum(Array([x0, y0]))
	dp = radiusPixels / nrings
	for rad in [0:dp:radiusPixels;]
		θ = LinRange(0, 2π, 500)
		x = x0 .+ rad*sin.(θ)
		y = y0 .+ rad*cos.(θ)
		Plots.plot!(fig, x, y, c=:red, legend=false)    
	end
	display(fig)
end

function getPgapArray(thresholdImage, zenithArray, nrings=9)
	dz = π / 2.0 / nrings
	zenithLims = collect(0:dz:π/2.0)
	# PgapArray = Array{Float64}(undef, nrings,2) * 0.0
	PgapDF = DataFrames.DataFrame(zenithRad=zeros(nrings), Pgap=zeros(nrings))
	for ringNo in collect(1:nrings)
		mask = (zenithArray .> zenithLims[ringNo]) .&&
				(zenithArray .<= zenithLims[ringNo+1])
		maskData = thresholdImage[mask]
		nPixels = length(maskData)
		nGaps =  sum(maskData)
		# PgapArray[ringNo,1] = (zenithLims[ringNo] + zenithLims[ringNo+1]) / 2.0
		# PgapArray[ringNo,2] = (nGaps / nPixels)
		PgapDF[ringNo,"zenithRad"] = (zenithLims[ringNo] + zenithLims[ringNo+1]) / 2.0
		PgapDF[ringNo,"Pgap"] = (nGaps / nPixels)
	end
	PgapDF
end

mutable struct LAIStruct
    PgapDF::DataFrames.AbstractDataFrame
	modelData::DataFrames.AbstractDataFrame
    model::GLM.StatsModels.TableRegressionModel{GLM.LinearModel{GLM.LmResp{Vector{Float64}}, GLM.DensePredChol{Float64, GLM.LinearAlgebra.CholeskyPivoted{Float64, Matrix{Float64}}}}, Matrix{Float64}}
    Lh::Float32
    Lv::Float32
    LAI::Float32
    ThetaL::Float32
    Cover::Float32
end

function getLAI(thresholdImage, zenithArray, nrings=9)

	PgapDF = getPgapArray(thresholdImage, zenithArray, nrings)

	zen = PgapDF[!,"zenithRad"]
	pgap = PgapDF[!,"Pgap"]
	x = 2/π.*tan.(zen)
	y = -log.(pgap)
	df = DataFrames.DataFrame(TwoTanTonPi=x, negLnPgap=y)
	
	# remove the first and last ring
	df = df[2:(size(df)[1]-1),:]
	model = GLM.lm(GLM.@formula(negLnPgap ~ TwoTanTonPi), df)
	
	Lh = GLM.coef(model)[1]
	Lv = GLM.coef(model)[2]
	
	LAI = sqrt(Lh^2 + Lv^2)
	ThetaLdeg = atan(abs(Lh/Lv)) * 180.0 / π
	Cover = 1.0 - exp(-abs(Lh))
	
	LAIData = LAIStruct(PgapDF, df, model, Lh, Lv, LAI, ThetaLdeg, Cover)
end


function plotLaiModel(LaiObj, titleLabel)
	# plot the linear model, note that "model" has confidence intervals for Lh and Lv
	dfStats = DataFrames.describe(LaiObj.modelData)

	Plots.plot(LaiObj.modelData[!,"TwoTanTonPi"], 
		LaiObj.modelData[!,"negLnPgap"], seriestype=:scatter, title=titleLabel)
	Plots.abline!(LaiObj.Lv, LaiObj.Lh, line=:dash, legend=false)

	xloc = (dfStats.min .+ ((dfStats.max .- dfStats.min) * 0.8))[1]
	yloc = (dfStats.min .+ ((dfStats.max .- dfStats.min) * 0.3))[2]
	Plots.annotate!(xloc, yloc, "LAI = "*string(round(LaiObj.LAI,digits=2)), :black)

	yloc = (dfStats.min .+ ((dfStats.max .- dfStats.min) * 0.2))[2]
	Plots.annotate!(xloc, yloc, "ThetaL = "*string(round(LaiObj.ThetaL,digits=2)), :black)

	yloc = (dfStats.min .+ ((dfStats.max .- dfStats.min) * 0.1))[2]
	Plots.annotate!(xloc, yloc, "Cover = "*string(round(LaiObj.Cover,digits=2)), :black)
end

end