function [sol, objv, t, converged] = pli_gmm_em(X, K, varargin)
%PLI_GMM_EM Estimates a Gaussian mixture model using EM
%
%   [sol, objv, t, converged] = PLI_GMM_EM(X, K, ...)
%   [sol, objv, t, converged] = PLI_GMM_EM(X, Q0, ...)
%
%       Estimates a Gaussian mixture model using EM algorithm.
%       One can either specify the number of components K or an initial
%       guess of the soft assignment matrix Q0.
%
%   Arguments
%   ---------
%   - X :       The matrix of observations. Each column in X is a sample.
%
%   - K :       The number of components, size = [d, n]. 
%
%   - Q0 :      An initial guess of the soft-assignment matrix.
%               The size of Q0 should be [K, n]. Here, n is the number
%               of samples.
%
%   One can specify other options to customize the estimation.
%
%   Options
%   -------
%   - covform :     The form of covariance: 
%                   's' | 'd' | {'f'} | 's-tied' | 'd-tied' | 'f-tied'
%
%   - weights :     The sample weights, which should be an n x 1 vector.
%                   (default = [], indicating all samples have the same
%                    unit weight.)
%
%   - pricount :    The prior count of each component. (default = 0)
%
%   - maxiter :     The maximum number of iterations. (default = 200)
%
%   - tolfun :      The tolerance of change in the objective function
%                   value at convergence. (default = 1.0e-8)
%
%   - display :     The level of information display: 
%                   'off' | 'final' | {'iter'}.
%
%   Returns
%   -------
%   - sol :         The optimized solution. 
%                   (Refers to fmm_em_problem for the details of the
%                    structure of the solution.)
%
%   - objv :        The objective value at final step.
%
%   - t :           The number of elapsed iterations.
%
%   - converged :   Whether the procedure converges.
%

%% argument checking

if ~(isreal(X) && isfloat(X) && ismatrix(X))
    error('pli_gmm_em:invalidarg', 'X should be a real matrix.');
end

% default options

S.covform = 'f';
S.weights = [];
S.pricount = 0;

S.maxiter = 200;
S.tolfun = 1.0e-8;
S.lasting = 5;
S.display = 'iter';

% override options

if ~isempty(varargin)
    S = pli_parseopts(S, varargin);
end

%% main

% problem construction

d = size(X, 1);
model = pli_gauss_model(d, S.covform); 

problem = pli_fmm_em_problem(model, S.pricount);


problem.set_obs(X, S.weights);

% initialize solution

sol = problem.init_solution(K);

% optimize solution

[sol, objv, t, converged] = pli_iteroptim('maximize', ...
    @problem.eval_objv, @problem.update, sol, ...
    'maxiter', S.maxiter, ...
    'tolfun', S.tolfun, ...
    'display', S.display);

