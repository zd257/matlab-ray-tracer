function [X Y] = rank1Lattice(nFibo)
% rank1Lattice
%   nFibo   - Uses the nth Fibonacci number.
%
% RETURN
%   X       - Horizontal coordiante for a pixel of 1 x 1.
%   Y       - Vertical coordinate.
%

%   Florian Raudies, 05/22/2013, Boston University.
Seq     = fibonacci(nFibo, 2);
n       = Seq(2);
Index   = (0 : n-1)';
X       = Index/n;
Y       = mod(Index/n*Seq(1), 1);
