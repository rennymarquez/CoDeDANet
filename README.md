# CoDeDANet

MATLAB implementation accompanying:

> Márquez, R., & Weber, R. (2023). Dynamic community detection including
> node attributes. *Expert Systems With Applications*, 223, 119791.
> https://doi.org/10.1016/j.eswa.2023.119791

CoDeDANet (**Co**mmunity **De**tection in **D**ynamic **A**ttributed
**Net**works) finds communities in networks whose links, nodes and node
attributes all change over time. It combines spectral clustering
(to fuse topology and attribute information at each time step) with a
tensor decomposition (to weigh current vs. past information across
time), and is compared against two baselines: a static attributed-graph
method (SwA, Tang et al., 2020) and a dynamic topology-only method
(DwoA, Al-sharoa et al., 2019). A third baseline, DALouvain (Bello
et al., 2016), is an external implementation - see the paper's
reference list.

## Getting started

1. Install the [Dependencies](#dependencies) below.
2. For the DANCer datasets (122-138) only, download the corresponding
   folders from Mendeley and place them under `datasets/` - see
   `datasets/README.md`. Nothing to download for the other datasets;
   they're generated on the fly.
3. From MATLAB, at the repo root:

```matlab
setup   % adds src/ to the path, creates CreateData/ and Results/
```

4. Run whichever script corresponds to the algorithm you want:

```matlab
codedanet   % the full CoDeDANet algorithm
swa         % SwA baseline
dwoa        % DwoA baseline
```

Each is a self-contained MATLAB script (not a function) with a block
of parameters near the top. The `init`/`initIn` flag controls where
those parameters come from:
- `init = 1`: use the values hardcoded in the script (including which
  dataset to run, via the `Data` variable).
- `init = 0` (default): skip that block and use whatever values are
  already in the workspace - useful for scripting many runs (e.g. a
  driver loop that sets `Data`, `seed`, etc. and calls the script
  repeatedly) without editing the file each time.

## Repository layout

```
CoDeDANet/
├── setup.m                        Adds everything below to the path
├── src/
│   ├── codedanet/
│   │   └── codedanet.m              The full CoDeDANet algorithm
│   ├── baselines/
│   │   ├── swa_spectral_attributes/swa.m    SwA baseline (Tang et al., 2020)
│   │   └── dwoa_alsharoa/dwoa.m             DwoA baseline (Al-sharoa et al., 2019)
│   ├── data_generation/            Synthetic network generators (called live, no download needed)
│   │   ├── SyntheticNetwork1.m       Data 17, 18 (Sheikholeslami & Giannakis, 2018)
│   │   ├── SyntheticNetwork2.m       Data 107, 108, 109 (Tang et al., 2020 - degree-corrected SBM)
│   │   ├── SyntheticNetwork3.m       Data 19-22 (Al-sharoa et al., 2019)
│   │   ├── trandn.m                  Truncated normal sampler used by SyntheticNetwork3.m
│   │   └── trandn_LICENSE.txt        trandn.m's own license (Zdravko I. Botev) - separate from this repo's LICENSE
│   ├── metrics/                    Evaluation metrics used in Section 4.1 of the paper
│   │   ├── getNMI.m         Normalized Mutual Information (MATLAB File Exchange, credited in-file)
│   │   ├── getVI.m          Variation of Information
│   │   ├── getMeasures.m    Jaccard, Precision, Sensitivity, Specificity, (Adjusted) Rand Index
│   │   ├── density.m        Partition density
│   │   ├── entropy.m        Attribute entropy
│   │   ├── modularity.m     Newman-Girvan modularity (MATLAB File Exchange, credited in-file)
│   │   ├── isSymmetric.m    \ 
│   │   ├── numEdges.m        > graph helpers used by density.m (matlab-networks-toolbox, credited in-file)
│   │   └── selfLoops.m      /
│   └── utils/
│       └── getProjectRoot.m        Portable repo-root lookup (replaces the old hardcoded paths)
├── datasets/                       Empty placeholder — see datasets/README.md
└── LICENSE
```

The COVID-19 and crime real-world networks, and DANCer-format raw-text
loading, from earlier iterations of this code are not part of the
current `codedanet.m` / `swa.m` / `dwoa.m` - see `datasets/README.md`.

## Dependencies

`setup.m` looks for the toolbox on the MATLAB path or in
  `third_party/tensor_toolbox*`, and offers to download v3.1 there if it
  is missing. To install it manually instead, download release v3.1
  (GitLab link above, or the GitHub mirror
  https://github.com/sandialabs/tensor_toolbox/releases/tag/v3.1),
  unzip it into `third_party/`, and run `setup`.

  Citation:
  ```bibtex
  @misc{TTB_Software,
    author = {Brett W. Bader and Tamara G. Kolda and others},
    title  = {{MATLAB} Tensor Toolbox, version 3.1},
    year   = {2019},
    url    = {https://gitlab.com/tensors/tensor_toolbox/-/releases/v3.1}
  }
  ```

## Data

See `datasets/README.md` for exactly which `Data` values need a
download from Mendeley and which are generated on the fly:
https://data.mendeley.com/datasets/fkz6mbpr2z


## Citation

If you use this code, please cite:

```bibtex
@article{marquez2023dynamic,
  title   = {Dynamic community detection including node attributes},
  author  = {M{\'a}rquez, Renny and Weber, Richard},
  journal = {Expert Systems With Applications},
  volume  = {223},
  pages   = {119791},
  year    = {2023},
  doi     = {10.1016/j.eswa.2023.119791}
}
```

## License

MIT — see `LICENSE`. Note that `src/data_generation/trandn.m`
carries its own separate license (`trandn_LICENSE.txt`, BSD-style,
Zdravko I. Botev) that must be kept alongside it, and that `getNMI.m`
and `modularity.m` under `src/metrics/` are credited to MATLAB File
Exchange / matlab-networks-toolbox in their own file headers.
