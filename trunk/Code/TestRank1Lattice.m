clc
clear all
close all

% *************************************************************************
% Generate a rank1 lattice for the 9th Fibonacci number. This will result
% in 34 sample points.
% *************************************************************************

[X Y] = rank1Lattice(5);
n = numel(X);


figure;
plot(X,Y,'b.');
for iter = 1:n, text(X(iter),Y(iter),num2str(iter-1)); end
xlabel('x (pixel)');
ylabel('y (pixel)');