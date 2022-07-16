# HemiPhoto

[![Build Status](https://github.com/gnewnham/HemiPhoto.jl/actions/workflows/CI.yml/badge.svg?branch=master)](https://github.com/gnewnham/HemiPhoto.jl/actions/workflows/CI.yml?query=branch%3Amaster)

This package us used for processing of upward facing hemispherical photography of forest canopies in order to quantify structural metrics such as leaf area index (LAI) and fractional cover. Both manual threshold based segmentation and automated binarization methods can be used. See "vignette.pdf" for details of the theory behind the methods.

# Example usage:
using HemiPhoto

file = "./test/Mt_Gowler_Hemi.jpg"
img = Images.load(file)
zenithArray = HemiLAI.getZenithArray(img)
thresholdImage = Thresholds.histogramThreshold(img, "Moments")
LaiObj = HemiLAI.getLAI(thresholdImage, zenithArray, 9)
HemiLAI.plotLaiModel(LaiObj, lab)
