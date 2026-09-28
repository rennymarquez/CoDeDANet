# Datasets

Datasets used in the paper. See the file `Data description` at the
repository root for how each one was generated. The same data is also
hosted on Mendeley Data: https://data.mendeley.com/datasets/fkz6mbpr2z

Every dataset folder contains 10 files, one per random seed:
`Data<id>.../Data<id>...S1.mat` to `...S10.mat`.

## Folder structure

```
datasets/
  Synthetic network 1/
    Data17R0M0/  Data17R0M1/  Data17R1M0/  Data17R1M1/    (40 % of nodes change community)
    Data18R0M0/  Data18R0M1/  Data18R1M0/  Data18R1M1/    (80 % of nodes change community)
  Synthetic network 2/
    Data107PV0.21/  Data107PV0.25/    Data107MinValS<seed>.mat / Data107MaxValS<seed>.mat
    Data108PV0.1/   Data108PV0.14/    Data108MinValS<seed>.mat / Data108MaxValS<seed>.mat
    Data109PV0.19/  Data109PV0.23/    Data109MinValS<seed>.mat / Data109MaxValS<seed>.mat
  Synthetic network 3/
    Data19R0M0/ ... Data22R1M1/       (same R/M pattern as Data17/Data18)
  Synthetic network 4 (DANCer)/
    Data122/ ... Data125/
    Data128/ ... Data131/
    Data135/ ... Data138/             Data<N>S<seed>.mat
```

- **R / M suffix** (networks 1 and 3): `R0M0` one relevant attribute,
  `R0M1` three attributes with one relevant, `R1M0` one irrelevant
  attribute, `R1M1` three irrelevant attributes.
- **PV folders** (network 2): `Data107`, `Data108` and `Data109` are the
  strongly assortative, weakly assortative and disassortative networks.
  `MinVal` / `MaxVal` files use the lower / upper end of the link
  probability range of each type (0.21-0.25, 0.1-0.14, 0.19-0.23).

## How `codedanet.m` / `swa.m` / `dwoa.m` get their data

The `Data` variable selects the case; each of the three main scripts
handles it the same way:

- **Data 17, 18** (Synthetic network 1) and **19-22** (Synthetic
  network 3): generated live, every run, by
  `src/data_generation/SyntheticNetwork1.m` and `SyntheticNetwork3.m`.
  Nothing to download for these - `seed` controls the random instance.
- **Data 107, 108, 109** (Synthetic network 2): generated live by
  `src/data_generation/SyntheticNetwork2.m`. Nothing to download here
  either.
- **Data 122-125, 128-131, 135-138** (Synthetic network 4 / DANCer):
  loaded from the saved `.mat` files in this folder:
```matlab
  load(fullfile(getProjectRoot(),'datasets','Synthetic network 4','Data122',"Data122S"+num2str(seed)));
```

Only the DANCer datasets (122-138) need anything downloaded to this
folder; the rest are generated on the fly from the functions in
`src/data_generation/`.

