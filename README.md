# sql-backpropagation-polynomial
EXCEL and SQL implementations for a simple BACKPROPAGATION use case :
- Excel model simulating the backpropagation algorithm
- Implementation of a backpropagation algorithm in **PostgreSQL** for polynomial regression, used to compare performance against an Excel model


## Files Included
- `modello.xlsx`: Source Excel file with the 4th-degree model. ⚠️ Excel Macro Instructions (.xlsm file)
- `/sql`: Folder containing SQL scripts:
  - `init.sql`: Initialization of tables and data.
  - `engine.sql`: `calculate_step_metrics` function.
  - `train.sql`: Recursive query for training.


## ⚠️ Excel Macro Instructions (.xlsm file)

The Excel file contains **VBA macros** required to run the backpropagation simulation. To ensure it works correctly, please follow these steps:

1.  **Enable Macros**: When you open the file, Excel might show a yellow security bar at the top. Click **"Enable Content"**.
2.  **Trusted Location (If necessary)**: If macros are blocked, you may need to move the file to a "Trusted Location" in Excel:
    * Go to **File** > **Options** > **Trust Center** > **Trust Center Settings** > **Trusted Locations**.
3.  **Run Simulation**: Use the buttons provided in the dashboard sheet to train the model and generate the loss curve.
