function F = Voigtprofile (unknown, wavelengths)

alpha = 0.000;  %ion broadening parameter, negligible according to Hans Griem and without Wr(beta) goes to unreasonable values
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
numsteps = size(wavelengths);
F = zeros(numsteps(1),1);

%Calculates the Lorentzian distribution, this is separate to save on
%processing time and because it doesn't change with wavelength.
for y = convintLB : convstepsize : convintUB
    % The lorentzian distribution
    calcLor(round((y-convintLB)/convstepsize+1)) = Lorfun(WR,y, centwavelength, unknown(1), unknown(2), alpha , 1);
end

% Calculates the convoluted distribution (Lorentzian + Gaussian), the first
% for loop steps through the wavelength and the second does the integration
% over y following the trapezoid rule.
for R = 1:1: numsteps(1)
    for y = convintLB : convstepsize : convintUB
        calcGauss = Gaussfun(unknown(4) , y , wavelengths(R));
        GaussLor = calcGauss * calcLor(round((y-convintLB)/convstepsize+1));
        psi = integration(psi, GaussLor, convintLB , convstepsize , y);
    end
    F(R,1) = unknown(3) * psi(1) + background;
end

    function value = integration( intvalues, equation, dstart, dstep, variable)
        if variable > dstart
            value(3) = intvalues(2);   % updating previous value for trapezoidal rule
            value(2) = equation;      %calculated value
            value(1) = trap( value(2) , value(3) , dstep) + intvalues(1); % trapezoidal integration steps
        else
            value(1) = 0;    % zeroing values
            value(3) = 0;
            value(2) = equation;     % first value of the trapezoidal rule
        end
        
        function value = trap(x1, x2, stepsize)
            value = stepsize*(x1+x2)/2;
        end
    end
end