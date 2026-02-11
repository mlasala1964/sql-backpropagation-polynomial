# sql-backpropagation-polynomial
EXCEL and SQL implementations for a simple BACKPROPAGATION use case :
- Excel model simulating the backpropagation algorithm
- Implementation of a backpropagation algorithm in **PostgreSQL** for polynomial regression, used to compare performance against an Excel model


## Files Included
- `modello.xlsx`: Source Excel file with the 4th-degree model.
- `/sql`: Folder containing SQL scripts:
  - `init.sql`: Initialization of tables and data.
  - `engine.sql`: `calculate_step_metrics` function.
  - `train.sql`: Recursive query for training.
