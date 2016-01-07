#=
A CPD is a Conditional Probability Distribution
In general, theyrepresent distribtions of the form P(X|Y)
Each node in a Bayesian Network is associated with a variable,
and contains the CPD relating that var to its parents, P(x | parents(x))
=#

# module CPDs

# using Reexport
# @reexport using Distributions
using Distributions
using DataFrames

export
    CPD,                         # the abstract CPD type

    Assignment,                  # variable assignment type, complete or partial, for a Bayesian Network
    NodeName,                    # variable name type

    distribution,                # returns the CPD's distribution type
    trained,                     # whether the CPD has been trained
    pdf,                         # probability density function or probability distribution function (continuous or discrete)
    learn!                       # train a CPD based on data


typealias NodeName Symbol
typealias Assignment Dict

abstract CPD{D<:UnivariateDistribution}
#=
Each CPD must implement:
    trained(CPD)
    Distributions.ncategories(CPD)
    learn!(CPD, BayesNet, NodeName, DataFrame)
    pdf(CPD, Assignment)
    cpd.name or name(CPD)
=#

distribution{D}(cpd::CPD{D}) = D
Base.rand(cpd::CPD, a::Assignment) = rand(pdf(cpd, a))
name(cpd::CPD) = cpd.name # all cpds have names by default

###########################

"""
The ordering of the parental instantiations in discrete networks follows the convention
defined in Decision Making Under Uncertainty.

Suppose a variable has three discrete parents. The first parental instantiation
assigns all parents to their first bin. The second will assign the first
parent (as defined in `parents`) to its second bin and the other parents
to their first bin. The sequence continues until all parents are instantiated
to their last bins.

This is a directly copy from Base.sub2ind but allows for passing a vector instead of separate items

Note that this does NOT check bounds
"""
function sub2ind_vec{T<:Integer}(dims::Tuple{Vararg{Integer}}, I::AbstractVector{T})
    N = length(dims)
    @assert(N == length(I))

    ex = I[N] - 1
    for i in N-1:-1:1
        if i > N
            ex = (I[i] - 1 + ex)
        else
            ex = (I[i] - 1 + dims[i]*ex)
        end
    end

    ex + 1
end

###########################

# """
# A CPD in which P(x|y) is a Bernoulli distribution
# """
# type Bernoulli <: CPD
#     parameterFunction::Function # a → P(x = true | a)
#     Bernoulli(parameter::Real = 0.5) = new(a->parameter)
#     Bernoulli(parameterFunction::Function) = new(parameterFunction)
#     function Bernoulli{A<:Any}(names::AbstractVector{NodeName}, dict::Dict{Dict{NodeName, A}, Float64})

#         param_func = a -> begin a
#             a2 = Dict{NodeName, Bool}()
#             for n in names
#                 a2[n] = a[n]
#             end
#             dict[a2]
#         end

#         new(param_func)
#     end
#     function Bernoulli(names::AbstractVector{NodeName}, dict::Dict{Vector{Int}, Float64})

#         #=
#         NOTE: the dict in this case is typically generated by rand_bernoulli_dict,
#               and maps a list of 0,1 values to true or false
#         =#

#         key = Array(Int, length(names))

#         param_func = a -> begin a

#             for (i,n) in enumerate(names)
#                 key[i] = convert(Int, a[n])
#             end
#             dict[key]
#         end

#         new(param_func)
#     end
# end
# domain(d::Bernoulli) = BINARY_DOMAIN
# probvec(d::Bernoulli, a::Assignment) = [d.parameterFunction(a), 1.0-d.parameterFunction(a)]
# function pdf(d::Bernoulli, a::Assignment)
#     (x) -> x != 0 ? d.parameterFunction(a) : (1 - d.parameterFunction(a))
# end
# function Base.rand(d::Bernoulli, a::Assignment)
#     rand() < d.parameterFunction(a)
# end

# """
# A CPD in which P(x|y) is a Gaussian
# """
# type Normal <: CPD
#     parameterFunction::Function # a → (μ, σ)
#     Normal(parameterFunction::Function) = new(parameterFunction)
#     Normal(mu::Real, sigma::Real) = new(a->(mu, sigma))
# end
# domain(d::Normal) = REAL_DOMAIN
# function pdf(d::Normal, a::Assignment)
#     (mu::Float64, sigma::Float64) = d.parameterFunction(a)
#     x -> begin x
#         z = (x - mu)/sigma
#         exp(-0.5*z*z)/(√2π*sigma)
#     end
# end
# function Base.rand(d::CPDs.Normal, a::Assignment)
#     mu, sigma = d.parameterFunction(a)::Tuple{Float64, Float64}
#     mu + randn() * sigma
# end

# end # module CPDs