include("bve_direct_stats_class_screening.jl")

times = [30, 60]
expdir = "../runs/samplingscreening/"

screening_summary(expdir::String, times, "bcs", "lns")
