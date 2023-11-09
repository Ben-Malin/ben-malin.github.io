## Turbulence Modelling: SST Blending Function

*The \\k-\omega\\ SST$* turbulence model is used to blend between the \\k-\omega\\ and \\k-\epsilon\\ models, in an attempt to get the best of both worlds.  
Until very recently, I'd never really thought to examine where each model was actually getting applied. Taking some things for granted in CFD is often necessary but dangerous...  

I was surprised to discover there wasn't already a simple way to plot the blending function builtin to OpenFOAM, at least not that I could find.  
So, I made a new function object to do just that, and I've put it up on github: [handyFunctionObjects](https://github.com/Ben-Malin/handyFunctionObjects)  

Check it out, and let me know if it comes in handy.

### Example:

Here it is in action. 
The case itself was something I threw together in the limited spare I don't have: estimating the drag on a monohull-style solar car (these things were my intro to CFD, one day I'll write up a post or two about them)

What I found interesting was the description I had in my head of "\\k-\omega\\ near the walls, \\k-\epsilon\\ everywhere else" isn't quite the reality.  
For other scenarios that may be the case, but not for this particular case and set of inlet conditions

Red indicates \\k-\omega\\, blue indicates \\k-\epsilon\\
![zoomedOut](/images/sstBlending/zoomedOut.png)  

![zoomedIn](/images/sstBlending/zoomedIn.png)  
