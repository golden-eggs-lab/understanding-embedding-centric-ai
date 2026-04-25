#!/usr/bin/env bash

echo "=== Acquiring datasets ==="
echo "---"

if [ -d "$PWD/data/" ]
then
  echo "Directory /data/ exists."
else
  echo "Create Directory /data."
  mkdir data
fi

# (1) SST-2
echo "Downloading SST-2 Dataset..."
if [ -d "$PWD/data/SST-2" ]
then
  echo "Directory /data/SST-2 exists."
else
  echo "Directory /data/SST-2 does not exist."
  python utilities/download_glue.py --tasks SST
fi
echo "---"

# (2) QQP
echo "Downloading QQP Dataset..."
if [ -d "$PWD/data/QQP" ]
then
  echo "Directory /data/QQP exists."
else
  echo "Directory /data/QQP does not exist."
  python utilities/download_glue.py --tasks QQP
fi
echo "---"

# (3) QNLI
echo "Downloading QNLI Dataset..."
if [ -d "$PWD/data/QNLI" ]
then
  echo "Directory /data/QNLI exists."
else
  echo "Directory /data/QNLI does not exist."
  python utilities/download_glue.py --tasks QNLI
fi
echo "---"

# (4) PubMed
# (5) IMDB (and local HuggingFace cache for bert-base-cased)
echo "IMDB Dataset and cached BERT model:"
echo "  Please place the IMDB dataset under 'data/IMDB/' and a local HuggingFace"
echo "  cache of 'bert-base-cased' under 'cache/bert-base-cased-local/'."
echo "  IMDB can be downloaded from https://ai.stanford.edu/~amaas/data/sentiment/"
echo "  and the BERT cache obtained via 'transformers-cli download bert-base-cased'."
echo "---"

# (6) AG_NEWS
# (7) DBPEDIA

echo "---"
echo "The End :)"
