function Gauss = Gaussianfit (unknown, xvalues)

alpha = 0.000 ;  %ion broadening parameter, negligible according to Hans Griem and without Wr(beta) goes to unreasonable values
WR = 1;

% User input constants
global centwavelength;  % center wavelength
global background;  % background level
global convsteps;  % number of convolution steps
global convintLB;  % convolution upper range
global convintUB;  % convolution Lower range

convstepsize = (convintUB - convintLB)/convsteps;

% equation important variables (don't change)
psi = [0,0,0];
numsteps = size(xvalues);
F = zeros(numsteps(1),1);
 
% for R = 1:1: numsteps(1)
%     for lambdaint = convintLB : convstepsize : convintUB
%         Gauss = Gaussfun(unknown(4) , centwavelength , xvalues(R));
%         IntGauss = integration(psi, psicalc, convintLB , convstepsize , lambdaint);
%     end
%     GaussFin(R,1) = IntGauss(1);
% end

for R = 1:1: numsteps(1)
    Gauss(R,1) = Gaussfun(unknown(4) , centwavelength , xvalues(R));
end