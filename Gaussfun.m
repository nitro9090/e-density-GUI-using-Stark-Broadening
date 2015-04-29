function value = Gaussfun(StdDev, y , lambda)

value = 1/(StdDev * (2*pi)^.5)*exp(-1*(lambda - y).^2/(2 * StdDev^2)); 
