---
description: A simple functionObject to output the SST blending function
tags: Turbulence
---

## Turbulence Modelling: SST Blending Function

**The \\(k\omega SST\\)** turbulence model is used to blend between the \\(k\omega\\) and \\(k\epsilon\\) models, in an attempt to get the best of both worlds.  
Until very recently, I'd never really thought to examine where each model was actually getting applied. Taking some things for granted in CFD is often necessary but dangerous...  

I was surprised to discover there wasn't already a simple way to plot the blending function builtin to OpenFOAM, at least not that I could find.  
So, I made a new function object to do just that, and I've put it up on github: [handyFunctionObjects](https://github.com/Ben-Malin/handyFunctionObjects)  

Check it out, and leave a comment if it comes in handy.

### Example:

Here it is in action.  
The case itself was something I threw together in the limited spare I don't have: estimating the drag on a monohull-style solar car (these things were my intro to CFD, one day I'll write up a post or two about them)

What I found interesting was the description I had in my head of "*\\(k\omega\\) near the walls, \\(k\epsilon\\) everywhere else*" isn't quite the reality.  
For other scenarios that may be the case, but not for this particular case and set of inlet conditions

Red indicates \\(k\omega\\), blue indicates \\(k\epsilon\\)  

![zoomedOut](/images/sstBlending/zoomedOut.png)  

![zoomedIn](/images/sstBlending/zoomedIn.png)  

### How it works:

The shear stress transport model calculates each of the model constants as a blend:  

$$
\phi = F_1\phi_1 + (1-F_1)\phi_2
$$  

Where \\( \phi_1 \\) is \\( k-\omega \\) model constant and \\( \phi_2 \\) is a corresponding \\( k-\epsilon \\) constant

The blending parameter \\( F_1 \\) is given by:  

$$
F_1 = tanh(arg_1^4)
$$  

$$
arg_1 = min \left[ max \left(\frac{\sqrt{k}}{\beta^* \omega d},\frac{500 \nu}{d^2 \omega}\right), \frac{4\rho\sigma_{\omega 2}k}{CD_{k\omega}d^2} \right]
$$

$$
CD_{k\omega} = max \left( 2\rho\sigma_{\omega 2}\frac{1}{\omega}\frac{\partial k}{\partial x_j}\frac{\partial \omega}{\partial x_j},10^{-20}\right)
$$

Each of these parameters is calculated by the turbulence model. Unfortunately, they're calculated as private functions, which means we can't just create a pointer or reference to the turbulence model

```c++
// This doesn't work - F1 is a private function
const turbulenceModel& turbModel = lookupObject<turbulenceModel>(turbulenceModel::propertiesName);
scalarField F1 = turbModel.F1();
```

Instead, I have simply duplicated the functions from the turbulence model. It's not an elegant way to do it, as there's some duplication of code and memory, but it does the job:

```c++
// Function that returns a volScalarField as a tmp<>
Foam::tmp<Foam::volScalarField> Foam::functionObjects::SSTBlending::F1
(
    // Function inputs
    const volScalarField& k, // reference to the tke field
    const volScalarField& omega,
    const volScalarField& mu,
    const scalar alphaOmega2, // Model constants
    const scalar Cmu
)
{
    // For incompressible, just set rho to 1 so the units come out right
    const dimensionedScalar rho("rho",dimDensity,1.0);

    volScalarField CDkOmega
    (
        (2*alphaOmega2)*(fvc::grad(k) & fvc::grad(omega))/omega
    );

    tmp<volScalarField> CDkOmegaPlus = max
    (
        CDkOmega,
        dimensionedScalar("1.0e-10",dimless/sqr(dimTime),1.0e-10)
    );

    tmp<volScalarField> arg1 = min
    (
        min
        (
            max
            (
                (scalar(1)/scalar(Cmu))*sqrt(k)/(omega*y_),
                scalar(500)*(mu)/(sqr(y_)*omega)
            ),
            (4*alphaOmega2)*k/(CDkOmegaPlus*sqr(y_))
        ),
        scalar(10)
    );
    
    return tanh(pow4(arg1));
}
```
