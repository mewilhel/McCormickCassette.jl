# Run LP tests
#=
for i in 1:4
    include("LP/Prob$i.jl")
end
=#

# Run QP tests
include("QP/Prob1.jl")
#include("QP/Prob2.jl")
#=
for i in 1:1
    include("QP/Prob$i.jl")
end
=#

# Run NLP tests
#=
for i in 1:3
    include("NLP/Prob$i.jl")
end
=#
# Run Implicit test problems
#include("Implicit/Ex5_1.jl")
#include("Ex5_2.jl")