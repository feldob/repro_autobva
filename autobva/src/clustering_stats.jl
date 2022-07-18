function uniqueclusters(df::DataFrame)
    gdfs = groupby(df, [:clustering])

    maxnow = 0
    for gdf in gdfs
        foreach(r -> r[:cluster] += maxnow, eachrow(gdf))
        maxnow = maximum(gdf[:, :cluster])
    end

    return df
end

function unique_clusterings(exps::Vector, lookup::Dict{DataFrameRow, Int64})
    covered = Vector{Any}(undef, length(exps))
    for (idx, exp) in enumerate(exps)
        res_frame = CSV.read(exp, DataFrame; type=String)
        res_frame = res_frame[:, Not(:count)]
        covered[idx] = unique!([ lookup[v] for v in eachrow(res_frame) ])
    end
    return covered
end

function clusteringsstats(expdir::String, clusterings_dir::String, times)
    expfiles = filter(x -> endswith(x, "_all.csv") && length(collect(eachmatch(r"_", x))) == 1, readdir(expdir))

    df_res = DataFrame(sut = String[],
                    time = Int[],
                    strategy = String[],
                    algorithm = String[],
                    groundtruthsize = Int[],
                    found_mean = Float64[],
                    found_sd = Float64[],
                    found_unique = Int[]
                    )

    for f in expfiles
        sutname = split(f, "_")[1]
        sutname |> println

        df_clusterings = CSV.read(joinpath(clusterings_dir, "$(sutname)_clustering.csv"), DataFrame; type = String)
        df_clusterings.cluster = parse.(Int64, df_clusterings.cluster)
        df_clusterings = uniqueclusters(df_clusterings)
        n_total = maximum(df_clusterings[:,:cluster])

        clust_lookup = Dict{DataFrameRow, Int64}()
        df_raw = df_clusterings[:,1:end-5] # fifth is count - remove too
        foreach(e -> clust_lookup[e[2]] = df_clusterings[e[1], :][:cluster], enumerate(eachrow(df_raw)))

        expfiles_sut = map(x -> joinpath(expdir, x), filter(x -> startswith(x, "$(sutname)_")  && !endswith(x, "_all.csv"), readdir(expdir)))

        for time in times
            for ss in ["bituniform"]

                h = filter(x -> contains(x, "bcs") && contains(x, "_$(ss)_") && contains(x, "_$(time)_"), expfiles_sut)
                r = filter(x -> contains(x, "lns") && contains(x, "_$(ss)_") && contains(x, "_$(time)_"), expfiles_sut)

                h_covered = unique_clusterings(h, clust_lookup)
                r_covered = unique_clusterings(r, clust_lookup)

                h_mean = mean(length.(h_covered))
                h_std = std(length.(h_covered))

                r_mean = mean(length.(r_covered))
                r_std = std(length.(r_covered))

                h_all = unique(vcat(h_covered...))
                r_all = unique(vcat(r_covered...))

                h_unique = setdiff(h_all, r_all)
                r_unique = setdiff(r_all, h_all)

                "$time, $ss:" |> println
                "h coverage: $h_mean ± $h_std" |> println
                "h unique: $(length(h_unique))" |> println
                "r coverage: $r_mean ± $r_std" |> println
                "r unique: $(length(r_unique))" |> println

                push!(df_res, (sutname,time, ss, "bcs", n_total, h_mean, h_std, length(h_unique)))
                push!(df_res, (sutname,time, ss, "lns", n_total, r_mean, r_std, length(r_unique)))
            end
        end
    end

    CSV.write(joinpath(clusterings_dir, "clustering_stats.csv"), df_res)
end

function lookupcolumns_names(df::DataFrame)
    output_idx = findfirst(names(df) .== "output")
    names_left = vcat(names(df)[1:output_idx-1], ["output"])
    names_right = map(n -> "n_$n", names_left)
    return vcat(names_left, names_right)
end

function incl_cluster_coverage(clusterings_file::String, exp_file::String, df_repr::DataFrame)
    df_clusterings = CSV.read(joinpath(clusterings_file), DataFrame; type = String)
    df_results = CSV.read(joinpath(exp_file), DataFrame; type = String)

    df_clusterings.cluster = parse.(Int64, df_clusterings.cluster)
    df_clusterings = uniqueclusters(df_clusterings)
    n_total = maximum(df_clusterings[:,:cluster])

    clust_lookup = Dict{DataFrameRow, Int64}()

    lnames = lookupcolumns_names(df_clusterings)

    df_raw = df_clusterings[:,lnames]
    foreach(e -> clust_lookup[e[2]] = df_clusterings[e[1], :][:cluster], enumerate(eachrow(df_raw)))

    clustcount = zeros(Integer, n_total)

    df_results_raw = df_results[:, lnames]
    for r in eachrow(df_results_raw)
        clustcount[clust_lookup[r]] += 1
    end

    clustcountfinal = zeros(Integer, n_total)

    for i in 1:n_total
        clustcountfinal[i] = clustcount[clust_lookup[df_repr[i,lnames]]]
    end

    df_repr.bcs = clustcountfinal

    return df_repr
end
