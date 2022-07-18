This repo contains the analysis replication package for the paper "Automated Black-Box Boundary Value Detection". Four softwares under test (SUTs) were investigated. All results are already added and pre-produced for the users convenience - the scripts simply reinstantiate the results.

Content:

- runs: directory with meta data per experimental execution. the samplingscreening subdirectory contains the results of the pre-study explained in Appendix A to determine a useful default sampling strategy.
- scripts: directory with all scripts to extract statistics.
- clusterings: directory containing the cluster assignment of all candidates. The screening subdirectory contains the results of the pre-study to determine a useful feature set as of Appendix B.
- suts.jl: the suts under investigation

To run the scripts with an installation of Julia (e.g. verified version 1.5.3), you can execute the shell script stats.sh in directory `autobva` on a linux-based operating system: `./stats.sh`.

The statistics can be found in:

- sampling screening stats under `runs/samplingscreening/screening_stats.csv`
- all summaries for detected candidates can be found in `runs` in a variety of ways in files ending on `_all.csv`.
- the overall coverage over individual candidates for RQ1 can be found in directory `run` in file `direct_stats_all.csv`
- clustering coverage statistics for RQ2 can be found in `clusterings/clustering_stats.csv`
- the representative summaries for RQ3 can be found in the clusterings directory for each SUT (files ending with `representatives.csv`)
