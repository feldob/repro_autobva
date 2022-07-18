function uniqueclusters(df::DataFrame)
    gdfs = groupby(df, [:clustering])

    maxnow = 0
    for gdf in gdfs
        foreach(r -> r[:cluster] += maxnow, eachrow(gdf))
        maxnow = maximum(gdf[:, :cluster])
    end

    return df
end

function representatives(df::DataFrame)
    gs = groupby(df, :cluster)
    ds = Vector{DataFrame}(undef, length(gs))
    for (idx, g) in enumerate(gs)
       ds[idx] = DataFrame(g)
    end

    df_indiv = map(d -> d[rand(1:nrow(d)),:], ds)
    df_red = DataFrame(df_indiv[1])
    foreach(d -> push!(df_red,d), df_indiv[2:end])
    return df_red
end

function representatives_shortest(df::DataFrame)
    gs = groupby(df, :cluster)

    ds = Vector{DataFrame}(undef, length(gs))
    for (idx, g) in enumerate(gs)
       ds[idx] = DataFrame(g)
    end

    foreach(g -> g.length = length.(string.(g.output, g.n_output)), ds)
    foreach(g -> sort!(g, :length), ds)
    
    df_first = map(d -> d[1,:], ds)
    df_red = DataFrame(df_first[1])
    foreach(d -> push!(df_red,d), df_first[2:end])
    return df_red
end

function assigncluster(df_exp::DataFrame, df_cl::DataFrame)
    entry_names = names(df_exp)[1:findfirst(x -> x == "count", names(df_exp))-1]
    
    d = Dict{DataFrameRow, Int64}()
    foreach(r -> d[r[entry_names]] = r.cluster, eachrow(df_cl))
    df_exp.cluster = Vector{Int64}(undef, nrow(df_exp))
    foreach(r -> r.cluster = d[r[entry_names]], eachrow(df_exp))

    dc = Dict{DataFrameRow, String}()
    foreach(r -> dc[r[entry_names]] = r.clustering, eachrow(df_cl))
    df_exp.clustering = Vector{String}(undef, nrow(df_exp))
    foreach(r -> r.clustering = dc[r[entry_names]], eachrow(df_exp))

    return df_exp
end

function representatives(expdir::String, sut::String, alg::String, nr::Integer=1)
    df_cl = CSV.read(joinpath(expdir * "_clusterings", sut * "_clustering.csv"), DataFrame; type = String)
    df_cl.cluster = parse.(Int64, df_cl.cluster)
    df_cl = uniqueclusters(df_cl)
    df_exp = CSV.read("$(expdir)/$(sut)_StringLength_$(alg)_bituniform_cts_600_$(nr).csv", DataFrame; type = String)

    df_exp = assigncluster(df_exp, df_cl)

    return representatives_shortest(df_exp)
end

function cluster_representatives(clust_dir::String, sut::String)
    df_o = CSV.read(joinpath(clust_dir, sut * "_clustering.csv"), DataFrame; type = String)
    df_o = df_o[:,Not([:UMAP1b, :UMAP2b, :type, :n_type, :metric])]

    gfs = groupby(df_o, [:clustering, :cluster]) # create grouping per clustering and cluster

    df_final = nothing
    for gf in gfs
        df = DataFrame(gf)
        df.length = length.(df.output) .+ length.(df.n_output)
        sort!(df, :length)

        r_shortest = DataFrame(df[1,:]) # extract a shortest variant
        r_shortest.clustermembers = [ nrow(df) ]
        r_shortest.memberhits = [ sum(parse.(Int64, df.count)) ]
        if isnothing(df_final)
            df_final = r_shortest
        else
            df_final = vcat(df_final, r_shortest) # combine shortest into common dataframe again
        end
    end

    sort!(df_final, [:clustering, :length])
    return hcat(DataFrame(clustering = df_final[:,:clustering]), df_final[:,Not([:clustering, :length, :memberhits, :count])])
end
