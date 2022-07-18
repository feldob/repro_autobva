include("bve_all_candidates.jl")

times = [30, 600]
algs = ["bcs", "lns"]
expdir = "../runs/"

singlefilesummary(expdir, times, algs)