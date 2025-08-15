function [Coefficients] = HexRegression(x,y)
% HexRegression Function
% Return the coefficients A-G for a 6th order polynomial regression given
% an input x,y data set.

% Define the type of function to fit using the fittype() function:
Fit=fittype(@(A,B,C,D,E,F,G,x) ...
    A*x.^6+B*x.^5+C*x.^4+D*x.^3+E*x.^2+F*x+G);
% Define Starting Values for Coefficients
x0=[1 1 1 1 1 1 1];
% Fit the function using the fit() function:
[fitted_curve,gof]=fit(x,y,Fit,'StartPoint',x0);

% Save the coefficient values from the fitting:
Coefficients=coeffvalues(fitted_curve);
% A = Coefficients(1);
% B = Coefficients(2);
% C = Coefficients(3);
% D = Coefficients(4);
% E = Coefficients(5);
% F = Coefficients(6);
% G = Coefficients(7);
end
