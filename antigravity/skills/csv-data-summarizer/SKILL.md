---
name: csv-data-summarizer
description: Analyzes CSV files, generates summary stats, and plots quick visualizations using Python and pandas.
---

# CSV Data Summarizer

This Skill analyzes CSV files and provides comprehensive summaries with statistical insights and visualizations.

## When to Use This Skill

- User uploads or references a CSV file
- Asks to summarize, analyze, or visualize tabular data
- Requests insights from CSV data
- Wants to understand data structure and quality

## CRITICAL BEHAVIOR REQUIREMENT

**DO NOT ASK THE USER WHAT THEY WANT TO DO WITH THE DATA.**
**DO NOT OFFER OPTIONS OR CHOICES.**
**IMMEDIATELY AND AUTOMATICALLY:**

1. Run the comprehensive analysis
2. Generate ALL relevant visualizations
3. Present complete results
4. NO questions, NO options, NO waiting for user input

## Automatic Analysis Steps

1. **Load and inspect** the CSV file into pandas DataFrame
2. **Identify data structure** - column types, date columns, numeric columns, categories
3. **Determine relevant analyses** based on what's actually in the data:
   - **Sales/E-commerce data**: Time-series trends, revenue analysis, product performance
   - **Customer data**: Distribution analysis, segmentation, geographic patterns
   - **Financial data**: Trend analysis, statistical summaries, correlations
   - **Operational data**: Time-series, performance metrics, distributions
   - **Survey data**: Frequency analysis, cross-tabulations, distributions
   - **Generic tabular data**: Adapts based on column types found

4. **Only create visualizations that make sense** for the specific dataset:
   - Time-series plots ONLY if date/timestamp columns exist
   - Correlation heatmaps ONLY if multiple numeric columns exist
   - Category distributions ONLY if categorical columns exist
   - Histograms for numeric distributions when relevant

5. **Generate comprehensive output** automatically including:
   - Data overview (rows, columns, types)
   - Key statistics and metrics relevant to the data type
   - Missing data analysis
   - Multiple relevant visualizations (only those that apply)
   - Actionable insights based on patterns found in THIS specific dataset

6. **Present everything** in one complete analysis - no follow-up questions

## Behavior Guidelines

✅ **DO:**

- Immediately run the analysis script
- Generate ALL relevant charts automatically
- Provide complete insights without being asked
- Be thorough and complete in first response
- Act decisively without asking permission

❌ **NEVER:**

- Ask what the user wants to do with the data
- List options for the user to choose from
- Wait for user direction before analyzing
- Provide partial analysis that requires follow-up
- Describe what you COULD do instead of DOING it

## Implementation

Use Python with pandas, matplotlib, and seaborn:

```python
import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns

def summarize_csv(file_path):
    df = pd.read_csv(file_path)
    
    # Basic info
    print(f"Dataset: {df.shape[0]} rows × {df.shape[1]} columns")
    print(f"\nColumn types:\n{df.dtypes}")
    print(f"\nMissing values:\n{df.isnull().sum()}")
    print(f"\nStatistics:\n{df.describe()}")
    
    # Auto-detect and visualize
    numeric_cols = df.select_dtypes(include='number').columns
    if len(numeric_cols) >= 2:
        plt.figure(figsize=(10, 8))
        sns.heatmap(df[numeric_cols].corr(), annot=True, cmap='coolwarm')
        plt.title('Correlation Heatmap')
        plt.savefig('correlation.png', dpi=150, bbox_inches='tight')
    
    return df
```

## Notes

- Automatically detects date columns
- Handles missing data gracefully
- All numeric columns are included in statistical summary
- Dependencies: python>=3.8, pandas>=2.0.0, matplotlib>=3.7.0, seaborn>=0.12.0
