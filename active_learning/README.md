# CAL — Contrastive Active Learning

**Task**: Active Learning (Table 1)  
**Invariants**: IV1 (Approximation → ANN), IV2 (Reuse → Probability Reuse)  
**Bottleneck Profile**: B1: 77.0±10.0%, B2: 10.5±6.5%, Total: 87.5±3.5%

## Code Origin

- **Upstream**: <https://github.com/mourga/contrastive-active-learning>
- **Status**: Authors' released code, vendored unchanged in its core algorithmic logic. Auxiliary baselines under `acquisition/` (BatchBALD, ALPS) are vendored from their respective upstream repositories, with the URL annotated in each file's header comment.
- **Our additions**: a unified CLI, timing/profiling instrumentation, the IV-aligned execution path (IV1: ANN backend via sklearn BallTree; IV2: probability cache across queries), and JSON/CSV result-output formatting. The original baseline path is selected via runtime flags (`--use_sklearn_ann`, `--cache_probabilities`) and is not modified.

## IV-Aligned Implementation

| Invariant | Original Execution                                                 | IV-Aligned Execution                         |
| --------- | ------------------------------------------------------------------ | -------------------------------------------- |
| IV1       | Exact KNN (brute-force)                                            | ANN (sklearn BallTree, leaf_size=40)         |
| IV2       | Recompute softmax probabilities for labeled samples at every query | Cache and reuse probabilities across queries |

## Datasets

| Dataset | Samples | Dim | Metric   | Acquisition                                   |
| ------- | ------- | --- | -------- | --------------------------------------------- |
| SST-2   | 67,349  | 768 | Accuracy | `bash get_data.sh`                            |
| IMDB    | 25,000  | 768 | Accuracy | Manual placement (see Setup)                  |

## Reproducing Results

### Setup

1. Install dependencies:

```bash
pip install -r requirements.txt
```

2. Download automated datasets (SST-2):

```bash
bash get_data.sh
```

3. Download manual dataset (IMDB) and local HuggingFace cache:

   `bash get_data.sh` already includes this step. It will fetch
   `cal_data_and_model.zip` (~470MB) from an anonymous OSF mirror and
   extract it into `data/IMDB/` and `cache/bert-base-cased-local/`. To
   download manually:

   ```bash
   wget -O cal_data_and_model.zip \
     "https://osf.io/download/69ec5cb2591194c4cb49dfd3/?view_only=9eb56ca83a904bc1b139485ba0c3c4ed"
   unzip cal_data_and_model.zip
   ```

### Exp 1: End-to-End (Table 3)

```bash
# Both SST-2 and IMDB, 3 runs each
bash run_e2e_comparison.sh

# SST-2 only
bash run_e2e_comparison.sh --dataset sst-2

# IMDB only
bash run_e2e_comparison.sh --dataset imdb

# Custom runs
bash run_e2e_comparison.sh --dataset sst-2 --num_runs 5

# Paper results:
#   SST-2: 1472.87s → 283.21s (-80.77%), Accuracy 90.36%
#   IMDB:  53.75s → 42.48s (-20.97%), Accuracy 96.89%
```

Or run individual experiments directly:

```bash
# Original
python run_al.py --dataset_name sst-2 --acquisition cal \
    --use_sklearn_ann False --cache_probabilities False \
    --seed 42 --init_train_data 1% --acquisition_size 2% --budget 15%

# IV-Aligned (IV1 + IV2)
python run_al.py --dataset_name sst-2 --acquisition cal \
    --use_sklearn_ann True --cache_probabilities True \
    --seed 42 --init_train_data 1% --acquisition_size 2% --budget 15%
```

### Exp 2: Ablation (Table 4)

```bash
bash run_ablation.sh
# Tests: Original / +IV1 / +IV2 / +All
```

### Exp 3: Component Breakdown (Table 5)

Component-level execution times (e.g., Training time, Test time, Inference time, Selection time, KNN Build, and KNN Search) are intrinsically logged and printed in the terminal at the end of each iteration during the standard `run_al.py` execution. No separate breakdown script is required.

### Exp 4: Overhead (Table 6)

Similar to Exp 3, the exact separation of Overhead (Index Build vs. Search Query Time) is natively reported in the `run_al.py` summary logs.

To measure peak cache memory overhead:

```bash
python measure_cache_memory.py
# Reports: peak cache size for probability reuse
```

### Exp 5: Cross-Setup (Table 7)

```bash
bash run_milvus_comparison.sh       # Milvus vector-database
bash run_spark_comparison.sh        # Spark distributed
```

### Exp 7: Dataset Size (Figure 4 top)

```bash
bash run_imdb_scaling.sh
# Varies dataset size ratio, reports recall + task performance + runtime ratio
```

### Exp 8: Cache Capacity (Figure 4 bottom-right)

```bash
python run_cache_benchmark_ratio.py
# Multi-algorithm cache benchmark covering CAL, KNNPrompting, SCIP, CRAIG, SemDeDup
```

### Exp 9: ANN Sweep (Figure 5)

```bash
python run_ann_hyperparam_cal.py
# Sweeps nlist/nprobe, reports selection recall + search time ratio
```

### View Results

```bash
python show_acc.py
python show_acc.py --ablation
```

## Key Files

| File                           | Description                                               |
| ------------------------------ | --------------------------------------------------------- |
| `run_al.py`                    | Main active learning experiment (all configs)             |
| `acquisition/cal.py`           | CAL with IV1 (ANN) + IV2 (probability reuse)              |
| `run_e2e_comparison.sh`        | Unified E2E: SST-2 + IMDB, original vs IV-aligned (Exp 1) |
| `run_ablation.sh`              | Ablation study (Exp 2)                                    |
| `measure_cache_memory.py`      | Overhead measurement (Exp 4)                              |
| `run_spark_comparison.sh`      | Spark distributed (Exp 5)                                 |
| `run_milvus_comparison.sh`     | Milvus (Exp 5)                                            |
| `run_imdb_scaling.sh`          | Dataset size ratio (Exp 7)                                |
| `run_cache_benchmark_ratio.py` | Cache capacity sweep — 5 algorithms (Exp 8)               |
| `run_ann_hyperparam_cal.py`    | ANN sweep (Exp 9)                                         |
