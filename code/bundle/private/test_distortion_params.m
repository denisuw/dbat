function [K,P,B]=test_distortion_params(s,e)
%TEST_DISTORTION_PARAMS Chi-square test of lens and affine distortion parameters.
%
%   [K,P,B]=test_distortion_params(S,E) computes p values from the
%   cumulative Chi-square distribution function for the lens and
%   affine distortion parameters. The structures S and E are given to
%   and returned by BUNDLE, respectively. The vector K returns the p
%   values for each radial distortion koefficient K1, K2, K3, treated
%   separately (DOF=1). The scalar P returns the p value for the P1,
%   P2 parameters together (DOF=2). The vector B returns the p values
%   for each affine distortion parameter B1, B2, treated separately
%   (DOF=1). NaN values are returned for unestimated parameters.
%
%See also: CUMCHI2, HIGH_IO_CORRELATIONS.


% Estimated IO values and their covariances.
x=s.IO;
CIO=bundle_cov(s,e,'CIO');
K=nan(3,1);
P=nan;
B=nan(2,1);

if ~isempty(e.final.factorized) && e.final.factorized.fail
    % Tests are useless if factorization failed.
    return;
end

% Test radial coefficients individually.
for i=1:length(K)
    % Chi-square statistic is (x-mu)'*inv(C)*(x-mu), where x is N(mu,C).
    ix=3+i;
    if s.estIO(ix)
        v=(x(ix)-0)^2/CIO(ix,ix);
        K(i)=cumchi2(v,1);
    end
end

% Test tangential coefficients together.
ix=7:8;
if all(s.estIO(ix))
    v=x(ix)'*(CIO(ix,ix)\x(ix));
    P=cumchi2(v,2);
end

% Test affine coefficients individually.
for i=1:length(B)
    % Chi-square statistic is (x-mu)'*inv(C)*(x-mu), where x is N(mu,C).
    ix=8+i;
    if s.estIO(ix)
        v=(x(ix)-0)^2/CIO(ix,ix);
        B(i)=cumchi2(v,1);
    end
end
