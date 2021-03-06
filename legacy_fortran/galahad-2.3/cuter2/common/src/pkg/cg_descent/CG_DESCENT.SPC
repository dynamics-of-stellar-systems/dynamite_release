1.d-5     gradtol      (relative stopping tolerance--see doc for StopFac)
-1.0d0    gnorm        (initial step size---see doc for Step. If <=0, use |g0|)
.1d0      delta        (Wolfe line search parameter)
.9d0      sigma        (Wolfe line search parameter)
1.d-6     eps          (perturbation parameter for computing fpert)
.66d0     gamma        (required decay factor in interval)
5.0d0     rho          (interval growth factor used to get bracketing interval)
.01d0     eta          (lower bound for cg's beta_k)
.01d0     psi0         (factor used in starting guess for iteration 1)
.1d0      psi1         (factor previous step multiplied by in QuadStep)
2.d0      psi2         (factor previous step is multipled by for startup)
1.d-12    QuadCutOff   (QuadStep if relative change in f > QuadCutOff)
0.d-12    StopFact     (factor multiplying starting |grad|_infty in StopRule)
1.d-3     AWolfeFac    (AWolfe = F => set AWolfe = T if |f-f0| < Awolfe_fac*Ck)
1.0d0     restart_fac  (restart cg in restart_fac*n iterations)
500.d0    maxit_fac    (terminate in maxit_fac*n iterations)
0.d0      feps         (stop when value change <= feps*|f|)
.7d0      Qdecay       (used in Qk update: Qk = Qdecay*Qk + 1)
50        nexpand      (number of grow/shrink allowed in bracket)
50        nsecant      (number of secant steps allowed in line search)
.true.    PertRule     (F => eps, T => eps*Ck)
.true.    QuadStep     (use initial quad interpolation in line search)
.false.   PrintLevel   F (no print) T (intermediate results)
.true.    PrintFinal   F (no print) T (print error messages, final error)
.true.    StopRule     T (|grad|_infty <= max(tol,|grad|_0*StopFact) F (... <= tol*(1+|f|))
.false.   AWolfe       F (Wolfe -- see AWolfeFac above) T (approx Wolfe)
.true.    Step         F (no initial line search guess) T (guess in gnorm)
.false.   debug        F (no debugging) T (check for no increase in f)
