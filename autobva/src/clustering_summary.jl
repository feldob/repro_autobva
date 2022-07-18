include("clustering_stats.jl")

expdir = "../runs/"
clusterings_dir = "../clusterings/"

clusteringsstats(expdir, clusterings_dir, [30, 600])