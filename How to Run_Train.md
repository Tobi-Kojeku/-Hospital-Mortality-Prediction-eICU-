HOW TO RUN (Hospital Mortality Prediction — Logistic Regression Baseline)



1\) Prerequisites



\- Python 3.x

\- Packages:

&#x20; pip install pandas numpy scikit-learn



2\) Confirm the required input CSV exists



This project’s training script expects a 6-hour feature summary CSV that already contains:

\- the target column: "y"

\- feature columns

\- ID column: "patientunitstayid"



The script hardcodes this path:



CSV\_PATH = *(Use your path)*

"C:\\Projects\\eicu-collaborative-research-database-demo-2.0.1\\eicu-collaborative-research-database-demo-2.0.1\\sqlite\\eICUextra\\eicu\_features\_6h\_logreg.csv"



If the file is missing, the script will raise FileNotFoundError.



3\) Run the training + evaluation



Run:

&#x20; python Train\_logreg.py



4\) Outputs produced by Train\_logreg.py



The script writes files to:

&#x20; results/



Files:

\- results/confusion\_matrix.txt

\- results/classification\_report.txt

\- results/metrics.json



The evaluation prints to the console:

\- ROC AUC

\- Accuracy

\- Confusion matrix (rows=true, cols=pred)

\- Classification report



Model details (for transparency):

\- Stratified train/test split: 80% train / 20% test (random\_state=42)

\- Pipeline:

&#x20; - SimpleImputer(strategy="median")

&#x20; - StandardScaler()

&#x20; - LogisticRegression(max\_iter=2000, class\_weight="balanced", random\_state=42)

\- Threshold for class prediction: 0.5



