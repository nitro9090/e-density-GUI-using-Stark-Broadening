function [ VDWHWHM ] = Vanderwaalsbroad(wavelength, IonE, alpha, UpperE, UpperOQN, LowerE, LowerOQN, nDensity, Tgas, reducedMass)
%Van Der Waals broadening term 
% Calculating the van der waals broadening based on "Plasma Broadening And
% Shifting of non-hydrogenic Spectral Lines: Present Status and
% Applications" by N. Konjevic (1999)

EH = 13.6; %eV, ionization energy of hydrogen

nUpperSq = EH/(IonE - UpperE);
nLowerSq = EH/(IonE - LowerE);

RUpperSq = .5 * nUpperSq *(5 * nUpperSq + 1 - 3 * UpperOQN * (UpperOQN + 1));
RLowerSq = .5 * nLowerSq *(5 * nLowerSq + 1 - 3 * LowerOQN * (LowerOQN + 1));

RSq = RUpperSq - RLowerSq;

% Van der Waals Broadening FWHM, nm
VDWHWHM = 8.18*10^(-12)*(wavelength*10^(-7))^2*(alpha*RSq)^(2/5)*(Tgas/reducedMass)^(3/10) * nDensity*10^7; 

end