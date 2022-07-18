# summarizing all candidates for a sut into a single file.

function summarize_per_sutname(expdir, sutname)
    summary_files = filter(f -> occursin(sutname * r"_\d*_all.csv", f) ,readdir(expdir)) # filenames
    summary_files |> println
    all_dfs = map(f -> CSV.read(expdir * f, DataFrame; type = String), summary_files)
    all_dfs = vcat(all_dfs...)
    all_dfs.count = parse.(Int64, all_dfs.count)
    gr = groupby(all_dfs, setdiff(names(all_dfs), ["count"]))
    df = combine(gr, :count => sum => :count)

    CSV.write("$(expdir)$(sutname)_all.csv", df)
end

function summarize_per_sutname_time(expdir, sutname, time)
    summary_files = filter(f -> startswith(f, "$(sutname)_") && endswith(f, "_$(time)_all.csv") ,readdir(expdir)) # filenames
    all_dfs = map(f -> CSV.read(expdir * f, DataFrame; type = String), summary_files)
    all_dfs = vcat(all_dfs...)
    all_dfs.count = parse.(Int64, all_dfs.count)
    gr = groupby(all_dfs, setdiff(names(all_dfs), ["count"]))
    df = combine(gr, :count => sum => :count)

    CSV.write("$(expdir)$(sutname)_$(time)_all.csv", df)
end

function singlefilesummary(expdir::String, times, algs)
    expfiles = filter(x -> endswith(x, ".csv") && x != "results.csv" && !endswith(x, "_all.csv"), readdir(expdir))
    sutnames = unique(map(x -> split(x, "_")[1], expfiles))

    for sutname in sutnames
        for time in times
            for alg in algs
                df = nothing
                expfiles_sut = map(x -> "$expdir$x", filter(x -> startswith(x, "$(sutname)_") && contains(x, "_$(time)_") && contains(x, "_$(alg)_") && !endswith(x, "_all.csv"), readdir(expdir)))
                for expfile in expfiles_sut
                    res_frame = CSV.read(expfile, DataFrame; type = String)
                    res_frame.count = parse.(Int64, res_frame.count)
                    if isnothing(df)
                        df = res_frame              # init
                    else
                        df = vcat(df, res_frame)    # append
                    end

                    gr = groupby(df, setdiff(names(df), ["count"]))
                    df = combine(gr, :count => sum => :count)
                end

                args = names(df)[1:findfirst(x -> x == "output", names(df))-1]

                sort!(df, args)
                CSV.write("$(expdir)$(sutname)_$(alg)_$(time)_all.csv", df)
            end
            # summmarize per sutname + time
            summarize_per_sutname_time(expdir, sutname, time)
        end
        
        summarize_per_sutname(expdir, sutname)
    end
end
