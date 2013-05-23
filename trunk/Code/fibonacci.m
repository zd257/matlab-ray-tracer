function Seq = fibonacci(n, k)
% fibonacci
%   n   - Computes the series up to the n-th Fibonacci number.
%   k   - Return the k last Fibonacci numbers. If k is not provided it is
%         set to 1.
%
% RETURN
%   Seq - Sequence with the k last Fibonacci numbers:
%         Seq = [F_{n-k+1}...F_{n}].
%

%   Florian Raudies, 05/22/2013, Boston University.

% Compute the Fibonacci numbers using the closed form.
if nargin<2, k = 1; end
Index   = (n-k+1 : n)';
f1      = (1+sqrt(5))/2;
f2      = (1-sqrt(5))/2;
Seq     = floor( (f1.^Index-f2.^Index)/(f1-f2) );
