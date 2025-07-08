import os
import re
import pandas as pd
from datetime import datetime, timedelta

# Define the mapping function
def map_time_to_date(time_value):
    # Base date (m0 is 30 June 2023)
    base_date = datetime(2023, 6, 30)
    # Extract the number after "m" and calculate the new date
    months_to_add = int(time_value[1:])  # Extract number after "m"
    new_date = base_date + timedelta(days=30 * months_to_add)  # Approximate month duration
    return new_date.strftime('%Y-%m-%d')  # Return formatted date

# Folder and regex pattern setup
folder_path = r"calculations\Rscript\Inputs\Base\IF\Insurance\2023"
pattern_str = r"^2023(_Cell)?(_NB)?_(Onerous|Non-onerous|Remaining)(_202)?\.csv$"
pattern = re.compile(pattern_str)

# Iterate through the files and modify the Time column
for file in os.listdir(folder_path):
    if re.match(pattern, file):
        file_path = os.path.join(folder_path, file)
        df = pd.read_csv(file_path)
        
        # Check if the 'Time' column exists and transform it
        if "Time" in df.columns:
            df["Time"] = df["Time"].apply(map_time_to_date)
        
        # Overwrite the same file
        df.to_csv(file_path, index=False)
        print(f"File overwritten: {file_path}")
