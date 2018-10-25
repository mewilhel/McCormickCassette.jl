function MOI.optimize!(m::Optimizer)

    ########### Reformulate DAG using auxilliary variables ###########
    #LoadDAG!(m); LabelDAG!(m)
    #NewVariableSize,NewVariableIndex = ProcessDAG!(m)
    NewVariableSize = length(m.VariableInfo)
    m.ContinuousNumber = NewVariableSize

    ########### Set Correct Size for Problem Storage #########
    m.CurrentLowerInfo.Solution = Float64[0.0 for i=1:NewVariableSize]
    m.CurrentLowerInfo.LowerVarDual = Float64[0.0 for i=1:NewVariableSize]
    m.CurrentLowerInfo.UpperVarDual = Float64[0.0 for i=1:NewVariableSize]
    m.CurrentUpperInfo.Solution = Float64[0.0 for i=1:NewVariableSize]

    # loads variables into the working model
    m.VItoSto = Dict{Int,Int}()
    for i=1:NewVariableSize m.VItoSto[i] = i end

    ###### OBBT Setup #####
    # Sets terms that OBBT will be performed on
    for i=1:NewVariableSize
        if m.NonlinearVariable[i]
            push!(m.OBBTVars,MOI.VariableIndex(i))
        end
    end

    # Get various other sizes
    num_nlp_constraints = length(m.NLPData.constraint_bounds)

    # Sets any unset functions to default values
    SetToDefault!(m)

    # Copies variables to subproblems
    PushVariables!(m)

    # Create initial node and add it to the stack
    CreateInitialNode!(m)

    # Build the JuMP NLP evaluator
    evaluator = m.NLPData.evaluator
    features = MOI.features_available(evaluator)
    has_hessian = (:Hess in features)
    init_feat = [:Grad]
    has_hessian && push!(init_feat, :Hess)
    num_nlp_constraints > 0 && push!(init_feat, :Jac)
    MOI.initialize(evaluator,init_feat)

    # Sets up relaxations terms that don't vary during iterations (mainly linear)
    RelaxModel!(m, m.InitialRelaxedOptimizer, m.Stack[1], m.Relaxation, load = true)

    # Sets upper bounding problem using terms specified in optimizer
    SetLocalNLP!(m)

    # Tests Initial Routines
    m.Preprocess(m,m.Stack[1])
    #feas1 = PoorManLP(m,m.Stack[1])
    #feas2 = OBBT(m,m.Stack[1])
    #m.UpperProblem(m,m.Stack[1])
    #m.Postprocess(m,m.Stack[1])

    # Runs the branch and bound routine
    #SolveNLP!(m)
end
