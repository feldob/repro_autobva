function argnames(sutname)
    if sutname == "Julia Date"
        return ["year", "month", "day"]
    elseif startswith(sutname, "BMI")
        return ["h", "w"]
    elseif sutname == "ByteCount"
        return ["bytes"]
    end
end

function main_quantitative_summary(expdir::String, times, firstalg, secondalg)
    expfiles = filter(x -> endswith(x, ".csv") && x != "results.csv" && !endswith(x, "_all.csv"), readdir(expdir))
    sutnames = unique(map(x -> split(x, "_")[1], expfiles))

    df = DataFrame(sut = String[],
                    time = Int[],
                    algorithm = String[],
                    groundtruthsize = Int[],
                    found_mean = Float64[],
                    found_sd = Float64[],
                    found_unique = Int[])
    
    for sutname in sutnames
        sutname |> println
        expfiles_sut = map(x -> "$expdir$x", filter(x -> startswith(x, "$(sutname)_")  && !endswith(x, "_all.csv"), readdir(expdir)))

        for time in times
            
            df_all = CSV.read("$(expdir)$(sutname)_$(time)_all.csv", DataFrame; type=String)
    
            h = filter(x -> contains(x, firstalg) && contains(x, "_$(time)_"), expfiles_sut)
            r = filter(x -> contains(x, secondalg) && contains(x, "_$(time)_"), expfiles_sut)
            
            entries_h = Vector{Integer}(undef, length(h))
            df_h = nothing
            for (idx, expfile) in enumerate(h)
                res_frame = CSV.read(expfile, DataFrame; type=String)
                entries_h[idx] = nrow(res_frame)
    
                res_frame[:,argnames(sutname)]
    
                if isnothing(df_h)
                    df_h = res_frame              # init
                else
                    df_h = vcat(df_h, res_frame)    # append
                end
                unique!(df_h, argnames(sutname))
            end
    
            "average for $firstalg: $(mean(entries_h))"|> println
            
            entries_r = Vector{Integer}(undef, length(r))
            df_r = nothing
            for (idx, expfile) in enumerate(r)
                res_frame = CSV.read(expfile, DataFrame; type=String)
                entries_r[idx] = nrow(res_frame)
    
                if isnothing(df_r)
                    df_r = res_frame              # init
                else
                    df_r = vcat(df_r, res_frame)    # append
                end
                unique!(df_r, argnames(sutname))
            end
    
            "average for $secondalg: $(mean(entries_r))"|> println
    
            i_h = map(Tuple, eachrow(df_h[:, argnames(sutname)]))
            i_r = map(Tuple, eachrow(df_r[:, argnames(sutname)]))
    
           push!(df, (sutname,time, firstalg, nrow(df_all), mean(entries_h), std(entries_h), length(setdiff(i_h,i_r))))
           push!(df, (sutname,time, secondalg, nrow(df_all), mean(entries_r), std(entries_r), length(setdiff(i_r,i_h))))
        end
    end
    
    CSV.write("$(expdir)direct_stats_all.csv", df)
end