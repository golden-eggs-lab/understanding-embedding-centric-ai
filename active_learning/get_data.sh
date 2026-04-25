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
echo "Downloading IMDB Dataset and cached BERT model..."
CAL_DATA_URL="https://osf.io/download/69ec5cb2591194c4cb49dfd3/?view_only=9eb56ca83a904bc1b139485ba0c3c4ed"
CAL_DATA_ZIP="cal_data_and_model.zip"
CAL_DATA_SHA256="29e50d271aa41d6303b9da40ea8f540bdf2431c23031ac711a9121c2090e5128"

if [ -d "$PWD/data/IMDB" ] && [ -d "$PWD/cache/bert-base-cased-local" ]; then
  echo "IMDB and BERT cache already present, skipping."
else
  if [ ! -f "$CAL_DATA_ZIP" ]; then
    echo "Downloading $CAL_DATA_ZIP (~470MB)..."
    wget --no-check-certificate -O "$CAL_DATA_ZIP" "$CAL_DATA_URL"
  fi
  if command -v sha256sum >/dev/null 2>&1; then
    echo "$CAL_DATA_SHA256  $CAL_DATA_ZIP" | sha256sum -c - || {
      echo "Checksum verification failed for $CAL_DATA_ZIP"; exit 1;
    }
  fi
  unzip -o "$CAL_DATA_ZIP"
  echo "Extracted IMDB to data/IMDB/ and BERT cache to cache/bert-base-cased-local/"
fi
echo "---"

# (6) AG_NEWS
# (7) DBPEDIA

echo "---"
echo "The End :)"
