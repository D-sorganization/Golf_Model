function [InputFunctionOutput] = HexPolyInputFunction(A,B,C,D,E,F,G,x)
% Compute the value of a 6th order polynomial given the coefficients and x
% value.
InputFunctionOutput=A*x.^6+B*x.^5+C*x.^4+D*x.^3+E*x.^2+F*x+G;
end