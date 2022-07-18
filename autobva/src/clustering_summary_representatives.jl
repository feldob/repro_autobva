include("selection_search.jl")
include("clustering_stats.jl")

suts = ["Julia Date", "ByteCount", "BMI", "BMI classification"]

clust_dir = "../clusterings/"

dfs = Dict()
for s in suts
    df = cluster_representatives(clust_dir, s)

    replace!(df.clustering, "valid" => "VV")
    replace!(df.clustering, "validerror" => "VE")
    replace!(df.clustering, "error" => "EE")

    clustfile = joinpath(clust_dir, s * "_clustering.csv")
    bcsfile = joinpath("../runs/", s * "_bcs_600_all.csv")
    df = incl_cluster_coverage(clustfile, bcsfile, df)
    dfs[s] = df

    CSV.write(joinpath(clust_dir, s * "_representatives.csv"), df)
end