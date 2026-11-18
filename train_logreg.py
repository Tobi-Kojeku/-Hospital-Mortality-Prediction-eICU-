import os
import json
import numpy as np
import pandas as pd

from sklearn.model_selection import train_test_split
from sklearn.preprocessing import StandardScaler
from sklearn.pipeline import Pipeline
from sklearn.impute import SimpleImputer
from sklearn.linear_model import LogisticRegression
from sklearn.metrics import (
    roc_auc_score, accuracy_score, confusion_matrix, classification_report
)

CSV_PATH = r"C:\Users\ade_k\OneDrive\Desktop\NZ JOBS\Projects\eicu-collaborative-research-database-demo-2.0.1\eicu-collaborative-research-database-demo-2.0.1\sqlite\eICUextra\eicu_features_6h_logreg.csv"
RANDOM_STATE = 42

if not os.path.exists(CSV_PATH):
    raise FileNotFoundError(f"CSV not found at: {CSV_PATH}")

df = pd.read_csv(CSV_PATH)
print("Shape:", df.shape)
print("Columns:", df.columns.tolist())

if "y" not in df.columns:
    raise KeyError("Column 'y' not found in CSV. Check the exported file.")

y = df["y"].astype(int)

id_col = "patientunitstayid" if "patientunitstayid" in df.columns else None
exclude = ["y"] + ([id_col] if id_col else [])
feature_cols = [c for c in df.columns if c not in exclude and c != "y"]

X = df[feature_cols]

# Original approach: train/test split only
X_train, X_test, y_train, y_test = train_test_split(
    X, y,
    test_size=0.2,
    stratify=y,
    random_state=RANDOM_STATE
)

model = Pipeline(steps=[
    ("imputer", SimpleImputer(strategy="median")),
    ("scaler", StandardScaler()),
    ("clf", LogisticRegression(
        max_iter=2000,
        class_weight="balanced",
        random_state=RANDOM_STATE
    ))
])

model.fit(X_train, y_train)

# Evaluate using fixed threshold 0.5
proba = model.predict_proba(X_test)[:, 1]
pred = (proba >= 0.5).astype(int)

roc_auc = roc_auc_score(y_test, proba)
acc = accuracy_score(y_test, pred)
cm = confusion_matrix(y_test, pred)
report_text = classification_report(y_test, pred, digits=4)

print("\n=== Evaluation ===")
print(f"ROC AUC: {roc_auc:.4f}")
print(f"Accuracy: {acc:.4f}")
print("Confusion matrix (rows=true, cols=pred):")
print(cm)
print("\nClassification report:")
print(report_text)

# Export results (important for your GitHub project)
results_dir = "results"
os.makedirs(results_dir, exist_ok=True)

with open(os.path.join(results_dir, "confusion_matrix.txt"), "w", encoding="utf-8") as f:
    f.write("Confusion matrix (rows=true, cols=pred):\n")
    f.write(str(cm))
    f.write("\n")

with open(os.path.join(results_dir, "classification_report.txt"), "w", encoding="utf-8") as f:
    f.write("=== Evaluation ===\n")
    f.write(f"ROC AUC: {roc_auc:.4f}\n")
    f.write(f"Accuracy: {acc:.4f}\n")
    f.write(f"Threshold: 0.5\n\n")
    f.write("Confusion matrix (rows=true, cols=pred):\n")
    f.write(str(cm))
    f.write("\n\nClassification report:\n")
    f.write(report_text)
    f.write("\n")

metrics = {
    "roc_auc": float(roc_auc),
    "accuracy": float(acc),
    "threshold": 0.5,
    "n_test": int(len(y_test)),
    "confusion_matrix": np.array(cm).tolist(),
    "classification_report": report_text
}

with open(os.path.join(results_dir, "metrics.json"), "w", encoding="utf-8") as f:
    json.dump(metrics, f, indent=2)

print(f"\nSaved results to: {os.path.abspath(results_dir)}")
