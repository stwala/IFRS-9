import os
import re
import pandas as pd
from datetime import datetime, timedelta

def standardize_time_column(df):
    """
    Standardize the 'Time' column to a consistent datetime format (YYYY-MM-DD).
    """
    if 'Time' in df.columns:
        # Handle numeric values (Excel serial dates)
        df['Time'] = pd.to_datetime(df['Time'], errors='coerce', origin='1899-12-30', unit='D')
        
        # Handle string values (e.g., YYYY-MM-DD)
        df['Time'] = pd.to_datetime(df['Time'], errors='coerce')  # Convert strings to datetime
        
        # Drop rows where 'Time' couldn't be converted
        df = df.dropna(subset=['Time'])
    else:
        print("No 'Time' column found in the DataFrame.")
    return df

# Main script
file_path = r"calculations\Rscript\Inputs\Base\IF\Insurance\2024"
year = 2024
pattern_str = rf"^{year}_NB"  # Regex pattern to match files starting with the year
pattern = re.compile(pattern_str)

if os.path.exists(file_path) and os.path.isdir(file_path):
    matched_files = []  # Initialize the list outside the loop
    combined_df = pd.DataFrame()  # Start with an empty DataFrame

    # Iterate over files in the directory
    for file_name in os.listdir(file_path):
        if re.match(pattern, file_name):
            print(f"Matched File: {file_name}")
            matched_files.append(file_name)

    print(f"Matched files list: {matched_files}")

    for file in matched_files:
        full_path = os.path.join(file_path, file)  # Get the full path of the file
        try:
            df = pd.read_csv(full_path)
            print(f"Processing file: {file}")

            # Standardize the 'Time' column
            df = standardize_time_column(df)

            # Merge with the combined DataFrame using 'Time' as the guide
            if combined_df.empty:
                combined_df = df
            else:
                combined_df = pd.merge(
                    combined_df, df, on='Time', how='outer', suffixes=('', '_new')
                )

                # Sum columns with similar names except 'Time'
                for col in combined_df.columns:
                    if col not in ['Time'] and col.endswith('_new'):
                        original_col = col.replace('_new', '')
                        combined_df[original_col] = combined_df[original_col].fillna(0) + combined_df[col].fillna(0)
                        combined_df.drop(columns=[col], inplace=True)

        except Exception as e:
            print(f"Error processing file {file}: {e}")

    # Save the final combined DataFrame
    output_file = os.path.join(file_path, "combined_processed.csv")
    combined_df.to_csv(output_file, index=False)
    print(f"Saved combined processed file: {output_file}")
else:
    print(f"Directory does not exist: {file_path}")
