"""
    Thermodynamics

Moist thermodynamic functions, e.g., for air pressure (atmosphere equation
of state), latent heats of phase transitions, saturation vapor pressures, and
saturation specific humidities.


## AbstractParameterSet's

Many functions defined in this module rely on CLIMAParameters.jl.
CLIMAParameters.jl defines several functions (e.g., many planet
parameters). For example, to compute the mole-mass ratio:

```julia
using CLIMAParameters.Planet: molmass_ratio
using CLIMAParameters: AbstractEarthParameterSet
struct EarthParameterSet <: AbstractEarthParameterSet end
param_set = EarthParameterSet()
_molmass_ratio = molmass_ratio(param_set)
```

Because these parameters are widely used throughout this module,
`param_set` is an argument for many Thermodynamics functions.

## Numerical methods for saturation adjustment

Saturation adjustment function are designed to accept
 - `sat_adjust_method` a type used to dispatch which numerical method to use

and a function to return an instance of the numerical method. For example:

 - `sa_numerical_method_ρpq` returns an instance of the numerical
    method. One of these functions must be defined for the particular
    numerical method and the particular formulation (`ρ-p-q_tot` in this case).

The currently supported numerical methods, in RootSolvers.jl, are:
 - `NewtonsMethod` uses Newton method with analytic gradients
 - `NewtonsMethodAD` uses Newton method with autodiff
 - `SecantMethod` uses Secant method
 - `RegulaFalsiMethod` uses Regula-Falsi method
"""
module Thermodynamics

using DocStringExtensions
using RootSolvers
using RootSolvers: AbstractTolerance
using KernelAbstractions: @print

using CLIMAParameters: AbstractParameterSet
using CLIMAParameters.Planet
const APS = AbstractParameterSet

Base.broadcastable(param_set::APS) = Ref(param_set)

# Allow users to skip error on non-convergence
# by importing:
# ```julia
# import Thermodynamics
# Thermodynamics.error_on_non_convergence() = false
# ```
# Error on convergence must be the default
# behavior because this can result in printing
# very large logs resulting in CI to seemingly hang.
error_on_non_convergence() = true

# Allow users to skip printing warnings on non-convergence
print_warning() = true

@inline q_pt_0(::Type{FT}) where {FT} = PhasePartition(FT(0), FT(0), FT(0))

include("states.jl")
include("relations.jl")
include("isentropic.jl")
include("config_numerical_method.jl")
include("TemperatureProfiles.jl")
include("TestedProfiles.jl")

Base.broadcastable(dap::DryAdiabaticProcess) = Ref(dap)
Base.broadcastable(phase::Phase) = Ref(phase)

end #module Thermodynamics.jl
