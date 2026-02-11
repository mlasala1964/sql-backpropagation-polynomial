# sql-backpropagation-polynomial
EXCEL and SQL implementations for a simple BACKPROPAGATION use case :
- Excel model simulating the backpropagation algorithm
- Implementation of a backpropagation algorithm in **PostgreSQL** for polynomial regression, used to compare performance against an Excel model


## Files Included
- `BackPropagation 1 Dimension with 4 grade - Good Case -.xlsm`: Source Excel file with the 4th-degree model. ⚠️ Excel Macro Instructions (.xlsm file)
- `/sql`: Folder containing SQL scripts:
  - `BackPropagation.Initialization.sql`: Initialization of tables and data.
  - `BackPropagation.CalculationEngine.sql`: `calculate_step_metrics` and `update_weights` functions.
  - `BackPropagation.Iterations.sql`: Recursive query for training.
  - `BackPropagation.Model By PolinomialDegree.sql`: Recursive query for training different polynomial n-degree models in a single run.
- `BackPropagation 1 Dimension with 4 grade - Bad Case -.xlsm`: Source Excel file initualized with a different dataset which puts the model into crisis 


## ⚠️ Excel Macro Instructions (.xlsm file)

The Excel file contains **VBA macros** required to run the backpropagation simulation. To ensure it works correctly, please follow these steps:

1.  **Enable Macros**: When you open the file, Excel might show a yellow security bar at the top. Click **"Enable Content"**.
2.  **Trusted Location (If necessary)**: If macros are blocked, you may need to move the file to a "Trusted Location" in Excel:
    * Go to **File** > **Options** > **Trust Center** > **Trust Center Settings** > **Trusted Locations**.
3.  **Press to Run the Model Training**: Use the buttons provided in the dashboard sheet to train the model and generate the fitting curve.
