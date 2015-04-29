function value = Lorfun(WR , y , wavelengthcenter, dse , wse, alpha , beta)

value = 1/pi * WR / (1+((y - wavelengthcenter - dse) / wse - alpha * beta^2)^2);