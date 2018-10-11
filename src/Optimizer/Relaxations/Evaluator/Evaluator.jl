"Storage for EAGO's NLP evaluator"
mutable struct FunctionSetStorage{T}
    nd::Vector{NodeData}
    adj::SparseMatrixCSC{Bool,Int}
    const_values::Vector{Float64}
    storage::Vector{T}
    grad_sparsity::Vector{Int}
    hess_I::Vector{Int}
    hess_J::Vector{Int}
    dependent_subexpressions::Vector{Int}
end

mutable struct SubexpressionSetStorage{T}
    nd::Vector{NodeData}
    adj::SparseMatrixCSC{Bool,Int}
    const_values::Vector{Float64}
    storage::Vector{T}
    linearity::Linearity
end

function SubexpressionSetStorage(nd::Vector{NodeData}, const_values, num_variables, subexpression_linearity, moi_index_to_consecutive_index)

    nd = replace_moi_variables(nd, moi_index_to_consecutive_index)
    adj = adjmat(nd)
    storage = zeros(length(nd))
    linearity = classify_linearity(nd, adj, subexpression_linearity)

    return SubexpressionStorage(nd, adj, const_values, storage, linearity[1])
end

"Container for calculating relaxations of nonlinear terms"
mutable struct Evaluator{T<:SetStorage} <: AbstractNLPEvaluator
    m::Model
    has_user_mv_operator::Bool
    variable_number::Int
    current_node::NodeBB
    disable_1storder::Bool
    disable_2ndorder::Bool
    has_nlobj::Bool
    has_reverse::Bool
    fw_repeats::Int
    objective::FunctionSetStorage
    constraints::Vector{FunctionSetStorage}
    subexpressions::Vector{SubexpressionSetStorage}
    subexpression_order::Vector{Int}
    subexpression_values::Vector{T}
    subexpression_linearity::Vector{Derivatives.Linearity}
    subexpressions_as_julia_expressions::Vector{Any}
    last_x::Vector{T}
    jac_storage
    user_output_buffer
    eval_objective_timer::Float64
    eval_constraint_timer::Float64
    eval_objective_gradient_timer::Float64
    eval_constraint_jacobian_timer::Float64
    eval_hessian_lagrangian_timer::Float64
    function Evaluator()
        d = new()
        d.constraints = FunctionSetStorage[]::Vector{Int}
        d.eval_objective_timer = 0.0
        d.eval_constraint_timer = 0.0
        d.eval_objective_gradient_timer = 0.0
        d.eval_constraint_jacobian_timer = 0.0
        d.eval_hessian_lagrangian_timer = 0.0
        return d
    end
end

include("Passes.jl")
include("GetInfo.jl")
include("Load.jl")
