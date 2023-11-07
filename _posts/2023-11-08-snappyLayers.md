## SnappyHexMesh: What do the layer settings do

SnappyHexMesh Features a number of cryptically named settings, with little indication of how they might be expected to influence the layer addition. The snappyHexMesh code is by far the most complicated out of anything in OpenFOAM, so it's not a simple matter to just go inspect the code to figure out what's going on.

To that end, I've produced an automated test to go through all the layer settings and see what happens when they're modified.

In the below images, white regions indicate full layer addition, while blue-black colours indicate fewer or no layers have been added. The goal is for the whole thing to be white, without compromising too much on mesh quality

---

![featureAngleSurface](/images/snappy/featureAngle_surface.png)
