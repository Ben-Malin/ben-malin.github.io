---
description: Using the fvOptions codedSource to do some cool stuff
tags: fvOptions
---

# fvOptions: Coded Source Term

The ability to inject code into the OpenFOAM solvers through the use of fvOptions can be surprisingly powerful, once you learn a bit of OpenFOAM coding.  
Unfortunately, there's a bit of a lack of good examples or walk-throughs of this capability, so it can be pretty tricky to learn at first.  

## Overview of the different parts

```c++
SourceTerm
{
    type            scalarCodedSource;  // or vectorCodedSource
    selectionMode   all;                // or cellSet / cellZone
    name            codedSource;        // doesn't really matter

    // Set the field we're manipulating - This needs to be a field
    // where an fvMatrix is getting solved, and calls fvOptions
    fields          (<field>);

    codeCorrect
    #{
        // gets given <field> as a reference named "field"
        // Same as if you did mesh_.lookupObject(<field>)
    #};

    codeAddSup // or codeAddSupRho for compressible/buoyant solvers
    #{
        // gets given the fvMatrix equation as "eqn"
        // also gets the density field as "rho" if using SupRho
    #};

    codeConstrain
    #{
        // gets given the fvMatrix equation as "eqn"
    #};
}
```

If we look at the momentum equation in simpleFoam, it's easy to see where each of these sections gets applied:
```c++
    tmp<fvVectorMatrix> tUEqn
    (
        fvm::div(phi, U)
      + turbulence->divDevReff(U)
     ==
        fvOptions(U) // applies codeAddSup
    );
    fvVectorMatrix& UEqn = tUEqn.ref();

    UEqn.relax();

    fvOptions.constrain(UEqn); // applies codeConstrain

    if (simple.momentumPredictor())
    {
        solve(UEqn == -fvc::grad(p));

        fvOptions.correct(U); // applies codeCorrect
    }
```

From this equation, we get some hints about what each term is for (at least in the instance of the momentum equation).
- Use AddSup to add source terms to the equation
- Use Constrain to modify the U equation before it gets solved
- Use Correct to make adjustments to the U values after they get calculated

Constrain might be used to fix the values within some cells to some known value. That way they'll be taken into account when the matrix gets solved.  
On the other hand, Correct can be used to make adjustments to the U field after it's been calculated, but before those values then get fed into the pressure equation. A common use case would be to put bounds on the allowable values (can help prevent models crashing during startup).

## Examples
The examples below only show the entries that have been modified or are relevant

#### Heat source as a function of tke and time
(I can't think of a reason you'd want such a source, the point is just to show how to load in other fields)
```c++
SourceTerm
{
    fields (h);

    codeAddSupRho
    #{
        // get a reference to the current time
        const time& runTime = mesh_.time();
        
        // get the cell volumes
        const scalarField& V = mesh_.V();

        // get a reference to the tke field
        const volScalarField& k = mesh_.lookupObject("k");

        // Reference to the source term in the equation
        // the values of this field get applied at the ==fvOptions(h) part of the fvMatrix
        // make sure not to use const, since we want to change it
        scalarField& sourceTerm = eqn.source();

        // loop over all the cells in the mesh
        forAll(V, celli)
        {
            // Use +=, eqn.source might include other terms that we
            // don't want to overwrite
            sourceTerm[celli] += runTime.value()*k[celli] / V[celli];
        }
    #};
}
```

#### Set the temperature in a cell zone
```c++
SourceTerm
{
    selectionMode   cellZone;
    cellZone        heatZone;
    fields (h);

    // we need access to the basic thermo code
    codeOptions
    #{
        -I$(LIB_SRC)/thermophysicalModels/basic/lnInclude
    #};
    codeInclude
    #{
        #include "basicThermo.H"
    #};

    codeConstrain
    #{
        // get a reference to the thermo model
        const auto& thermo = mesh_.lookupObject<basicThermo>(basicThermo::dictName);
        // lookup a reference field (you could create it using something like setExprFields)
        const scalarField& Tref = mesh_.lookupObject<volScalarField>("Tref");
        // we also need the pressure field
        const volScalarField& p = thermo.p();
    
        // since we set the selection mode to cellZone, the cells_ variable holds the cells
        // in the zone
        // use thermo.he to get the enthalpy for the T that we want
        eqn.setValues(cells_, thermo.he(thermo.p(), Tref, cells_));
    #};
}
