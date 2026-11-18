# -Hospital-Mortality-Prediction-eICU-NZ(West,South,Midwest,Northeast)
# Hospital Mortality Prediction (eICU) — Logistic Regression Baseline

## Overview
This project implements an end-to-end pipeline for predicting **hospital mortality** using the **eICU Collaborative Research Database Demo**.
The goal is to forecast mortality from **time-windowed clinical features** derived from vitals and selected laboratory measurements.

A **Logistic Regression** model is trained as a baseline classifier and evaluated using standard discrimination metrics (ROC AUC) and classification metrics (confusion matrix, precision/recall, F1).

> **Note:** The achieved predictive performance is **not strong enough for clinical decision-making**. This work is intended primarily to demonstrate reproducible data extraction, feature construction, model training, and evaluation.

---

## Dataset
- **Source:** PhysioNet eICU Collaborative Research Database Demo
- **Local database (provided/exported):** `eicu_v2_0_1.sqlite3`
- **Task:** Predict **hospital mortality**
  - Target label is defined using `apachepatientresult`:
    - `y = 1` for **EXPIRED**
    - `y = 0` for **ALIVE**

### Cohort construction (time-windowing)
Features are extracted from the ICU stay by constructing a **6-hour window** summary:
- **Vitamins:** minimum values over the window (e.g., `sys`, `hr`, `temp`, oxygenation measures, etc.)
- **Labs:** selected laboratory variables summarised via aggregation over the same time window

Final modeling dataset:
- Number of unique stays after label extraction: **1838**
- After joining with the 6-hour minimum feature summaries: **1790 rows**

---

## Features
### Vitals (6-hour minimums)
The vitals summary includes:
- `sys`, `temp`, `sao2`, `rr`, `hr`, `cvp`, `etco2`, `dia`, `mean`
- arterial pressure variables: `pa_sys`, `pa_dia`, `pa_mean`
- neuro/ICU measurements: `st1`, `st2`, `st3`, `icp`

### Labs (6-hour values via LEFT JOIN)
Selected laboratory features included:
- bedside glucose, potassium, sodium, chloride
- creatinine, bun
- hemoglobin, lactate
- bicarbonate

---

## Methods

### Data pipeline (SQLite + SQL)
1. Use SQL CTEs to:
   - extract the mortality label per stay
   - compute time-windowed feature summaries 
2. Perform LEFT JOINs to preserve cohort size while adding missing labs where possible.
3. Verify row count consistency in SQL/DBeaver.
4. Export the feature matrix and label vector to CSV for model training.

---

### Model
**Logistic Regression baseline**
- Implemented in Python using `sqlite3`/CSV inputs and `scikit-learn`
- Outputs a probability estimate:  
  \[
  \hat{p}(y=1 \mid X)
  \]

---

### Evaluation Protocol
Performance is assessed using:
- **ROC AUC** to measure ranking/discrimination quality.
- **Classification metrics** (confusion matrix, precision, recall, F1) based on an operational threshold.

Class 1 corresponds to mortality (**EXPIRED**). Since mortality is relatively rare, class-specific performance is emphasised.

---

## Results

- **ROC AUC:** `0.6268`
- **Accuracy:** `0.6927`

### Confusion matrix (rows=true, cols=pred)
[235  92]
[ 18  13]
