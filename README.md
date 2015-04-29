# e-density-GUI-using-Stark-Broadening
An GUI for use in determining the electron density of a plasma using Stark Broadening

This code takes in an absolutely calibrated optical emission spectrum from single spectral line input as a text file and 
does a non-linear fit to the data to determine the electron density of a plasma based on how the line is stark broadened. 
Unless using a line with strong stark broadening (like the H balmer lines) a low neutral pressure is generally necessary (<1 Torr), 
The details of this method are discussed in my dissertation ("CO2 dissociation using the versatile atmospheric dielectric 
barrier discharge experiment (VADER)," which is freely available online.

The input text file format is frequency in column 1 and intensity in column 2.  
The code allows for an estimation of the background levels taken from the wings of the data, by specifying 
the wavelength range of the background level.

The "data range to use for fitting" is the range of wavelengths used for plotting the data.
The "data range for the voigt Integral: is the data to be used for calculating the voigt profile 
and effects the accuracy of the fit. Therefore it is important that the range cover the entire emission spectrum.  However,
going above that range will only slow down the calculations and any additional peaks should be avoided.
The number of steps effects the step size of integration, higher numbers will give a finer detail to the fitting,
but will take considerably longer.  10-20 is usually enough.

Data needed for the fit can either be put in manually or some pre-tabulated values for specific emission wavelengths may be used.
By unchecking any of the boxes to the left of a parameter allows for manual input of that variable. 
As this is a non-linear fit, users need to give an initial value for the electron impact shift (usually small, like .01 or -.05), 
electron impact half-width-half-max (HWHM) (also relatively small .1 ish), a normalizing factor (generally large, the voigt 
profile is multiplied by this value to scale it to the graph) and gaussian HWHM (also usually small, .1 ish).

When you hit start deconvoultion, the algorithm will only use values loaded into the input values and will output the final
values for each in the calculated/used section.  
Hit the update manual parameters button to load any values in the manual input section in for the input values, all units 
to be used are specified.  
