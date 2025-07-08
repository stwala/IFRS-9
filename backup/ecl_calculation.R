#!/usr/bin/env Rscript

# ========================================================
# COMPLETE ECL ANALYSIS SCRIPT (WITH ALL FILE PATHS)
# ========================================================

# ----------------------------
# 1. PACKAGE SETUP
# ----------------------------
required_packages <- c(
  "readxl", "dplyr", "ggplot2", "tidyr", "survival", 
  "survminer", "openxlsx", "waterfalls", "car"
)

# Install and load packages
for (pkg in required_packages) {
  if (!require(pkg, character.only = TRUE, quietly = TRUE)) {
    install.packages(pkg, repos = "https://cloud.r-project.org/")
    library(pkg, character.only = TRUE)
  }
}

# ----------------------------
# 2. CONFIGURATION WITH FILE PATHS
# ----------------------------
args <- commandArgs(trailingOnly = TRUE)

# Verify we received exactly 3 input files
if (length(args) != 3) {
  stop("Usage: Rscript ecl_analysis.R <main_dataset> <updated_dataset> <scenarios_file>")
}

# Assign input files from command line
config <- list(
  input_file = args[1],
  updated_file = args[2],
  scenarios_file = args[3],
  
  # Output files (relative to working directory)
  output_files = list(
    initial_results = "outputs/1.1Updated_dataset_after_12_months.xlsx",
    stage_results = "outputs/1.22Updated_dataset_after_12_months.xlsx",
    ecl_results = "outputs/updated_dataset_with_stage_ECL.xlsx",
    summary_results = "outputs/summaryECL.xlsx",
    report_results = "outputs/IFRS9_ECL_Report_Combined.xlsx",
    survival_results = "outputs/Survival_ECL_Output.xlsx",
    visualization_dir = "outputs/visualizations"
  ),
  
  # Model parameters
  LGD = 0.45,
  lifetime_PD_multiplier = 2.5,
  diamond_stress = list(
    pd_multiplier = 2.0,
    lgd_stressed = 0.50,
    ead_drawdown_factor = 1.10
  ),
  
  # Visualization parameters
  plot_width = 10,
  plot_height = 8,
  plot_dpi = 300
)

# ----------------------------
# 3. DATA PROCESSING FUNCTIONS
# ----------------------------
load_and_prepare_data <- function(file_path) {
  cat("Loading data from:", file_path, "\n")
  df <- read_excel(file_path)
  
  # Convert factors
  factor_cols <- c("employment_status", "marital_status", "product_type", "region",
                   "education", "employment_type", "profession", "exposure_level", "product_mix")
  df <- df %>% mutate(across(any_of(factor_cols), as.factor))
  
  # Convert numeric columns
  numeric_cols <- c("age", "income", "residence_years", "credit_score", "number_of_loans",
                    "loan_amount", "loan_term_months", "payment_to_income_ratio",
                    "debt_to_income_ratio", "delinquencies_12m", "utilization_rate",
                    "account_age_months", "collateral_value", "ltv_ratio",
                    "employment_duration_years", "cooperation_length_years",
                    "avg_loan_amount", "days_past_due", "loan_frequency", "query_count",
                    "delinquency_history", "exposure_level", "orig_exposure", "exposure_ratio",
                    "delinq_to_exposure", "off_balance_limit_usage", "cash_txn_count",
                    "cashless_txn_count", "repayment_pattern_score", "bank_history_score",
                    "age_income_interaction", "region_income_interaction")
  df[numeric_cols] <- lapply(df[numeric_cols], function(x) as.numeric(as.character(x)))
  
  # Simulate default if missing
  if (!"default_event" %in% colnames(df)) {
    set.seed(42)
    df$default_event <- rbinom(nrow(df), 1, 0.1)
  }
  
  return(df)
}

# ----------------------------
# 4. FIXED ECL CALCULATION
# ----------------------------
calculate_ecl <- function(df, LGD = 0.45) {
  cat("Calculating Expected Credit Loss...\n")
  
  # First ensure all required columns exist
  required_cols <- c("predicted_PD", "loan_amount", "off_balance_limit_usage", "orig_exposure")
  missing_cols <- setdiff(required_cols, colnames(df))
  
  if (length(missing_cols) > 0) {
    stop(paste("Missing required columns:", paste(missing_cols, collapse = ", ")))
  }
  
  # Calculate EAD first
  df <- df %>%
    mutate(
      EAD = loan_amount + (off_balance_limit_usage * orig_exposure),
      
      # Add error checking for numeric values
      stage1_ECL = ifelse(
        is.numeric(predicted_PD) & is.numeric(EAD),
        predicted_PD * LGD * EAD,
        NA_real_
      )
    )
  
  # Check for NA values
  na_count <- sum(is.na(df$stage1_ECL))
  if (na_count > 0) {
    warning(paste(na_count, "NA values generated in stage1_ECL calculation"))
  }
  
  total_ECL <- sum(df$stage1_ECL, na.rm = TRUE)
  cat("Total Stage 1 ECL for Portfolio:", round(total_ECL, 2), "\n")
  
  return(df)
}

# ----------------------------
# 5. VISUALIZATION FUNCTIONS
# ----------------------------
save_all_visualizations <- function(df, df12) {
  cat("Saving visualizations to:", config$output_files$visualization_dir, "\n")
  
  # Create directory if needed
  if (!dir.exists(config$output_files$visualization_dir)) {
    dir.create(config$output_files$visualization_dir, recursive = TRUE)
  }
  
  # 1. ECL Stage Performance Plot
  stage_file <- file.path(config$output_files$visualization_dir, "ecl_stage_performance.png")
  stage_plot <- df12 %>%
    group_by(stage) %>%
    summarise(count = n()) %>%
    ggplot(aes(x = factor(stage), y = count, fill = factor(stage))) +
    geom_bar(stat = "identity") +
    labs(title = "ECL Stage Distribution")
  ggsave(stage_file, stage_plot, width = config$plot_width, height = config$plot_height, dpi = config$plot_dpi)
  
  # 2. Loan Amount vs Income
  income_file <- file.path(config$output_files$visualization_dir, "loan_vs_income.png")
  income_plot <- ggplot(df12, aes(x = income, y = loan_amount)) +
    geom_point(color = "steelblue") +
    labs(title = "Loan Amount vs Income")
  ggsave(income_file, income_plot, width = config$plot_width, height = config$plot_height, dpi = config$plot_dpi)
  
  # 3. Age Band Analysis (Income)
  age_income_file <- file.path(config$output_files$visualization_dir, "income_by_age_band.png")
  age_income <- df12 %>%
    mutate(age_band = cut(age, breaks = seq(20, 80, by = 10))) %>%
    group_by(age_band) %>%
    summarise(avg_income = mean(income, na.rm = TRUE)) %>%
    ggplot(aes(x = age_band, y = avg_income)) +
    geom_col(fill = "cornflowerblue") +
    labs(title = "Average Income by Age Band")
  ggsave(age_income_file, age_income, width = config$plot_width, height = config$plot_height, dpi = config$plot_dpi)
  
  # 4. Loan Stages Breakdown
  stage_breakdown_file <- file.path(config$output_files$visualization_dir, "stage_breakdown.png")
  stage_breakdown <- df12 %>%
    group_by(stage) %>%
    summarise(count = n()) %>%
    ggplot(aes(x = factor(stage), y = count, fill = factor(stage))) +
    geom_col() +
    labs(title = "Loan Stage Breakdown")
  ggsave(stage_breakdown_file, stage_breakdown, width = config$plot_width, height = config$plot_height, dpi = config$plot_dpi)
  
  cat("Visualizations saved successfully\n")
}

# ----------------------------
# 6. MAIN EXECUTION
# ----------------------------
main <- function() {
  cat("\n=== STARTING ECL ANALYSIS ===\n")
  
  tryCatch({
    # Load and process data
    df <- load_and_prepare_data(config$input_file)
    df12 <- load_and_prepare_data(config$updated_file)
    
    # Calculate PDs and ECL
    df <- calculate_pd(df)
    df <- calculate_ecl(df, config$LGD)
    df12 <- calculate_pd(df12)
    
    # Stage allocation
    df12 <- df12 %>%
      mutate(
        initial_PD = df$predicted_PD[match(customer_id, df$customer_id)],
        pd_ratio = predicted_PD12 / initial_PD,
        stage = case_when(
          delinquencies_12m >= 3 ~ 3,
          pd_ratio > 2 ~ 2,
          TRUE ~ 1
        ),
        EAD = loan_amount + (off_balance_limit_usage * loan_amount),
        lifetime_PD = ifelse(stage == 1, predicted_PD12, pmin(predicted_PD12 * config$lifetime_PD_multiplier, 1)),
        ECL = lifetime_PD * config$LGD * EAD
      )
    
    # Generate outputs
    save_all_visualizations(df, df12)
    
    # Save results
    write.xlsx(df, config$output_files$initial_results)
    write.xlsx(df12, config$output_files$stage_results)
    write.xlsx(df12, config$output_files$ecl_results)
    
    # Summary report
    summary_ECL <- df12 %>%
      group_by(stage) %>%
      summarise(
        total_ECL = sum(ECL, na.rm = TRUE),
        avg_PD = mean(lifetime_PD, na.rm = TRUE),
        avg_EAD = mean(EAD, na.rm = TRUE),
        count = n()
      )
    write.xlsx(summary_ECL, config$output_files$summary_results)
    
    cat("\n=== ANALYSIS COMPLETED SUCCESSFULLY ===\n")
    cat("Output files created:\n")
    cat(paste("-", config$output_files$initial_results), "\n")
    cat(paste("-", config$output_files$stage_results), "\n")
    cat(paste("-", config$output_files$ecl_results), "\n")
    cat(paste("-", config$output_files$summary_results), "\n")
    cat(paste("- Visualizations in:", config$output_files$visualization_dir), "\n")
    
  }, error = function(e) {
    cat("\n=== ERROR OCCURRED ===\n")
    cat("Error:", e$message, "\n")
    traceback()
  })
}

# Run the analysis
main()