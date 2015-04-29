function Lor = Lorenzfit (unknown, xvalues)

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
 
for R = 1:1: numsteps(1)
    Lor(R,1) = Lorfun(WR , xvalues(R) , centwavelength , unknown(1) , unknown(2), alpha, 1);
end

end

