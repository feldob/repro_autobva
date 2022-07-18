# requires the all stats files from bve_all_candidates.jl to be in place.

function screening_summary(expdir::String, times, firstalg, secondalg)
    expfiles = filter(x -> endswith(x, ".csv") && x != "results.csv" && !endswith(x, "_all.csv"), readdir(expdir))
    sutnames = unique(map(x -> split(x, "_")[1], expfiles))

    df = DataFrame(time = Int[],
                    algorithm = String[],
                    cts = Bool[],
                    ss = String[],
                    found_mean = Float64[],
                    found_sd = Float64[])

    for sutname in sutnames

        for ss in ["bituniform", "uniform"]
            for cts in [true, false]
                expfiles_sut = nothing
                if cts
                    expfiles_sut = map(x -> "$expdir$x", filter(x -> startswith(x, "$(sutname)_") && contains(x, "_$(ss)_") && !endswith(x, "_all.csv") && contains(x, "_cts_"), readdir(expdir)))
                else
                    expfiles_sut = map(x -> "$expdir$x", filter(x -> startswith(x, "$(sutname)_")  && contains(x, "_$(ss)_") && !endswith(x, "_all.csv") && !contains(x, "_cts_"), readdir(expdir)))
                end

                for time in times

                    h = filter(x -> contains(x, firstalg) && contains(x, "_$(time)_"), expfiles_sut)
                    r = filter(x -> contains(x, secondalg) && contains(x, "_$(time)_"), expfiles_sut)

                    entries_h = Vector{Integer}(undef, length(h))
                    df_h = nothing
                    for (idx, expfile) in enumerate(h)
                        res_frame = CSV.read(expfile, DataFrame; type=String)

                        res_frame = unique!(res_frame, [:output, :n_output])[:,[:output, :n_output]]
                        entries_h[idx] = nrow(res_frame)

                        if isnothing(df_h)
                            df_h = res_frame              # init
                        else
                            df_h = vcat(df_h, res_frame)    # append
                        end
                        df_h = unique!(df_h)
                    end
                    
                    "average for rds: $(mean(entries_h))"|> println
                    
                    entries_r = Vector{Integer}(undef, length(r))
                    df_r = nothing
                    for (idx, expfile) in enumerate(r)
                        res_frame = CSV.read(expfile, DataFrame; type=String)

                        res_frame = unique!(res_frame, [:output, :n_output])[:,[:output, :n_output]]
                        entries_r[idx] = nrow(res_frame)

                        if isnothing(df_r)
                            df_r = res_frame              # init
                        else
                            df_r = vcat(df_r, res_frame)    # append
                        end
                        df_r = unique!(df_r)
                    end
                    
                    "average for random: $(mean(entries_r))"|> println
                    
                    if !isnan(mean(entries_h))
                        push!(df, (time, firstalg, cts, ss, mean(entries_h), std(entries_h)))
                        push!(df, (time, secondalg, cts, ss, mean(entries_r), std(entries_r)))
                    end
                end
            end
        end
    end

    sort!(df, [:time, :algorithm, :ss, :cts], rev = [false, true, true, false])

    CSV.write("$(expdir)screening_stats.csv", df)
    return df
end