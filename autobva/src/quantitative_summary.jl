include("bve_direct_stats.jl")

times = [30, 600]
expdir = "../runs/"

main_quantitative_summary(expdir, times, "bcs", "lns")