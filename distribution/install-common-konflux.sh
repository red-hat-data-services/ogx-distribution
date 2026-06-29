#!/bin/bash
# Konflux hermetic-build variant of install-common.sh.
# Instead of downloading model files from the internet, this script copies
# pre-fetched artifacts deposited by Hermeto's generic fetcher.
# The file list and checksums are defined in artifacts.lock.yaml.
set -euo pipefail

CACHI2_GENERIC="/cachi2/output/deps/generic"

mkdir -p "${APP_ROOT}/.ogx" "${APP_ROOT}/.cache"

# ---------- tiktoken cl100k_base ----------
export TIKTOKEN_CACHE_DIR="${APP_ROOT}/.cache/tiktoken"
mkdir -p "${TIKTOKEN_CACHE_DIR}"
# Filename in the cache is the SHA-1 of the download URL
cp "${CACHI2_GENERIC}/tiktoken/cl100k_base.tiktoken" \
   "${TIKTOKEN_CACHE_DIR}/9b5ad71b2ce5302211f9c61530b329a4922fc6a4"

# ---------- ibm-granite/granite-embedding-125m-english ----------
# Recreate the HuggingFace hub cache layout so SentenceTransformer resolves it.
HF_CACHE="${HOME}/.cache/huggingface/hub"
GRANITE_DIR="${HF_CACHE}/models--ibm-granite--granite-embedding-125m-english"
SNAPSHOT_DIR="${GRANITE_DIR}/snapshots/prefetched"
mkdir -p "${SNAPSHOT_DIR}/1_Pooling" "${GRANITE_DIR}/refs"

for f in config.json model.safetensors modules.json \
         sentence_bert_config.json special_tokens_map.json \
         tokenizer.json tokenizer_config.json; do
    cp "${CACHI2_GENERIC}/granite-embedding/${f}" "${SNAPSHOT_DIR}/${f}"
done
cp "${CACHI2_GENERIC}/granite-embedding/1_Pooling/config.json" \
   "${SNAPSHOT_DIR}/1_Pooling/config.json"

echo -n "prefetched" > "${GRANITE_DIR}/refs/main"

# ---------- docling-layout-heron ----------
HERON_DIR="${DOCLING_ARTIFACTS_PATH}/docling-project--docling-layout-heron"
mkdir -p "${HERON_DIR}"
for f in config.json model.safetensors preprocessor_config.json; do
    cp "${CACHI2_GENERIC}/docling-heron/${f}" "${HERON_DIR}/${f}"
done

# ---------- docling-models / tableformer ----------
TF_DIR="${DOCLING_ARTIFACTS_PATH}/docling-project--docling-models"
mkdir -p "${TF_DIR}/model_artifacts/tableformer/accurate"
cp "${CACHI2_GENERIC}/docling-models/model_artifacts/tableformer/accurate/tableformer_accurate.safetensors" \
   "${TF_DIR}/model_artifacts/tableformer/accurate/tableformer_accurate.safetensors"
cp "${CACHI2_GENERIC}/docling-models/model_artifacts/tableformer/accurate/tm_config.json" \
   "${TF_DIR}/model_artifacts/tableformer/accurate/tm_config.json"

# ---------- DocumentFigureClassifier-v2.5 ----------
FIGCLS_DIR="${DOCLING_ARTIFACTS_PATH}/docling-project--DocumentFigureClassifier-v2.5"
mkdir -p "${FIGCLS_DIR}"
for f in config.json model.safetensors preprocessor_config.json; do
    cp "${CACHI2_GENERIC}/docfigclassifier/${f}" "${FIGCLS_DIR}/${f}"
done

# ---------- RapidOCR ----------
RAPIDOCR_DIR="${DOCLING_ARTIFACTS_PATH}/RapidOcr"
mkdir -p "${RAPIDOCR_DIR}/onnx/PP-OCRv4/cls" \
         "${RAPIDOCR_DIR}/onnx/PP-OCRv4/det" \
         "${RAPIDOCR_DIR}/onnx/PP-OCRv4/rec" \
         "${RAPIDOCR_DIR}/paddle/PP-OCRv4/rec/ch_PP-OCRv4_rec_mobile" \
         "${RAPIDOCR_DIR}/paddle/PP-OCRv4/rec/en_PP-OCRv4_rec_mobile" \
         "${RAPIDOCR_DIR}/resources/fonts"

cp "${CACHI2_GENERIC}/rapidocr/onnx/PP-OCRv4/cls/ch_ppocr_mobile_v2.0_cls_mobile.onnx" \
   "${RAPIDOCR_DIR}/onnx/PP-OCRv4/cls/ch_ppocr_mobile_v2.0_cls_mobile.onnx"
cp "${CACHI2_GENERIC}/rapidocr/onnx/PP-OCRv4/det/ch_PP-OCRv4_det_mobile.onnx" \
   "${RAPIDOCR_DIR}/onnx/PP-OCRv4/det/ch_PP-OCRv4_det_mobile.onnx"
cp "${CACHI2_GENERIC}/rapidocr/onnx/PP-OCRv4/det/en_PP-OCRv3_det_mobile.onnx" \
   "${RAPIDOCR_DIR}/onnx/PP-OCRv4/det/en_PP-OCRv3_det_mobile.onnx"
cp "${CACHI2_GENERIC}/rapidocr/onnx/PP-OCRv4/rec/ch_PP-OCRv4_rec_mobile.onnx" \
   "${RAPIDOCR_DIR}/onnx/PP-OCRv4/rec/ch_PP-OCRv4_rec_mobile.onnx"
cp "${CACHI2_GENERIC}/rapidocr/onnx/PP-OCRv4/rec/en_PP-OCRv4_rec_mobile.onnx" \
   "${RAPIDOCR_DIR}/onnx/PP-OCRv4/rec/en_PP-OCRv4_rec_mobile.onnx"
cp "${CACHI2_GENERIC}/rapidocr/paddle/PP-OCRv4/rec/ch_PP-OCRv4_rec_mobile/ppocr_keys_v1.txt" \
   "${RAPIDOCR_DIR}/paddle/PP-OCRv4/rec/ch_PP-OCRv4_rec_mobile/ppocr_keys_v1.txt"
cp "${CACHI2_GENERIC}/rapidocr/paddle/PP-OCRv4/rec/en_PP-OCRv4_rec_mobile/en_dict.txt" \
   "${RAPIDOCR_DIR}/paddle/PP-OCRv4/rec/en_PP-OCRv4_rec_mobile/en_dict.txt"
cp "${CACHI2_GENERIC}/rapidocr/resources/fonts/FZYTK.TTF" \
   "${RAPIDOCR_DIR}/resources/fonts/FZYTK.TTF"

# ---------- all-MiniLM-L6-v2 tokenizer ----------
MINILM_DIR="${DOCLING_ARTIFACTS_PATH}/all-MiniLM-L6-v2"
mkdir -p "${MINILM_DIR}"
cp "${CACHI2_GENERIC}/minilm-tokenizer/tokenizer.json" "${MINILM_DIR}/tokenizer.json"
cp "${CACHI2_GENERIC}/minilm-tokenizer/tokenizer_config.json" "${MINILM_DIR}/tokenizer_config.json"

# ---------- Fix ownership and permissions ----------
chown -R 1001:0 "${DOCLING_ARTIFACTS_PATH}"
chmod -R g=u "${DOCLING_ARTIFACTS_PATH}"
