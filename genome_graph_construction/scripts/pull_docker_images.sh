#!/bin/bash
# Pull all Docker images required for the pipeline

set -e

echo "=== Pulling Docker Images for Pangenome Pipeline ==="
echo ""

# Cactus
echo "[1/4] Pulling Cactus..."
docker pull quay.io/comparative-genomics-toolkit/cactus:v3.1.2

# DeepVariant
echo "[2/4] Pulling DeepVariant..."
docker pull google/deepvariant:1.10.0-beta

# Manta
echo "[3/4] Pulling Manta..."
docker pull quay.io/biocontainers/manta:1.6.0--h9ee0642_2

# Sniffles
echo "[4/4] Pulling Sniffles..."
docker pull quay.io/biocontainers/sniffles:2.4--pyhdfd78af_0

echo ""
echo "=== All Docker images pulled successfully ==="
echo ""
echo "Listing downloaded images:"
docker images | grep -E "cactus|deepvariant|manta|sniffles"
