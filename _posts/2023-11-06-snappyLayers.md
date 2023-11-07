## SnappyHexMesh: What do the layer settings do

SnappyHexMesh Features a number of cryptically named settings, with little indication of how they might be expected to influence the layer addition. The snappyHexMesh code is by far the most complicated out of anything in OpenFOAM, so it's not a simple matter to just go inspect the code to figure out what's going on.

To that end, I've produced an automated test to go through all the layer settings and see what happens when they're modified.

In the below images, white regions indicate full layer addition, while blue-black colours indicate fewer or no layers have been added. The goal is for the whole thing to be white, without compromising too much on mesh quality

---
First up, I tested what happens with all the mesh quality controls disabled. 
The result is better layer coverage, which isn't too surprising. The goal is to get as good layer coverage as we can without having to disable or significantly wind back the quality controls.
For the rest of the tests below, mesh quality controls are left as their defaults. 
![QualityControlsSurface](/images/snappy/MeshQualityControls_surface.png)

Feature angle adjusts whether layers should collapse at sharp corners. 
Unsurprisingly, higher angles result in better layer coverage. 
![featureAngleSurface](/images/snappy/featureAngle_surface.png)

![maxFaceThicknessSurface](/images/snappy/maxFaceThickness_surface.png)

![maxThicknessToMedialRatioSurface](/images/snappy/maxThicknessToMedialRatio_surface.png)

![minMedialAxisAngleSurface](/images/snappy/minMedialAxisAngle_surface.png)

![minThicknessSurface](/images/snappy/minThickness_surface.png)

![nGrowSurface](/images/snappy/nGrow_surface.png)

![nSmoothNormalsSurface](/images/snappy/nSmoothNormals_surface.png)

![nSmoothSurfaceNormalsSurface](/images/snappy/nSmoothSurfaceNormals_surface.png)

![nSmoothThicknessSurface](/images/snappy/nSmoothThickness_surface.png)
