# Install and load required packages
required_packages <- c(
  "readxl", "dplyr", "car", "ggplot2", "tidyr", "openxlsx",
  "waterfalls", "survival", "survminer", "data.table"
)
for (pkg in required_packages) {
  if (!require(pkg, character.only = TRUE)) {
    install.packages(pkg)
    library(pkg, character.only = TRUE)
  }
}



args <- commandArgs(trailingOnly = TRUE)

if (length(args) != 3) {
  stop("Usage: Rscript ecl_analysis.R <credit_dataset> <updated_dataset> <scenarios_file>")
}

credit_input <- args[1]
updated_input <- args[2]
scenarios_input <- args[3]

#Extended_customer_credit_dataset == credit_input
#1.0updated_dataset_after_12_months == updated_input
#economic_scenarios <- scenarios_input


output_dir <- "output"
if (!dir.exists(output_dir)) dir.create(output_dir, recursive = TRUE)

# STEP 1: Load the Excel file

# Replace 'your_file.xlsx' with your actual file path

df <- read_excel(credit_input)
# View(df)

# STEP 2: Convert appropriate columns to factors

df <- df %>%
  mutate(across(c(
    employment_status, marital_status, product_type, region, education,
    employment_type, profession, exposure_level
  ), as.factor))



# Convert to numeric safely

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

factor_cols <- c("employment_status", "marital_status", "product_type", "region",
                 "education", "employment_type", "profession", "product_mix")

df[factor_cols] <- lapply(df[factor_cols], as.factor)


# STEP 3: Assume a 'default_event' binary column exists for modeling (you can add it if needed)

# For demo, we simulate one if it's not there


#-----------------Replacement--------------------------------

if (!"default_event" %in% colnames(df)) {
  set.seed(42)
  df$default_event <- rbinom(nrow(df), 1, 0.9)}

#---------------------------------------------------


# STEP 4: Fit the logistic regression model

model <- glm(default_event ~ . -customer_id, data = df, family = binomial)

# STEP 4: Fit the logistic regression model (using fewer predictors)

model <- glm(default_event ~ age + income + employment_status + loan_amount + delinquencies_12m, data = df, family = binomial)


# STEP 5: View model summary

#summary(model)

# STEP 6: Predict PD for the first customer

pd_customer_1 <- predict(model, newdata = df[1, ], type = "response")

pd_customer_all <- predict(model, newdata = df[, ], type = "response")

# Predict PDs for ALL customers

df$predicted_PD <- predict(model, newdata = df, type = "response")

df$predicted_PD12 <- predict(model, newdata = df, type = "response")

#View(df$predicted_PD)

cat("Predicted PD for Customer 1:", round(pd_customer_1, 4), "\n")


#----------------------------------------------------------------------------------------------

#STEP 7: Determination of EAD

# Assumptions

LGD <- 0.45

# Step 1: Calculate EAD

df$EAD <- df$loan_amount + (df$off_balance_limit_usage * df$orig_exposure)

# Step 2: Calculate Stage 1 ECL

df$stage1_ECL <- df$predicted_PD * LGD * df$EAD

# Step 3: Preview results

head(df[, c("customer_id", "predicted_PD", "EAD", "stage1_ECL")])

total_ECL_stage1 <- sum(df$stage1_ECL, na.rm = TRUE)

cat("Total Stage 1 ECL for Portfolio:", round(total_ECL_stage1, 2), "\n")

# install.packages("openxlsx")

# library(openxlsx)

# Summary

#table(df$stage)

# Export to Excel
write.xlsx(df, file.path(output_dir, "1.1Updated_dataset_after_12_months.xlsx"))



#############################################################===========================================================

# STEP 1: Load the Excel file

# Replace 'your_file.xlsx' with your actual file path

df12 <- read_excel(updated_input)

# STEP 2: Convert appropriate columns to factors
library(readxl)
df12 <- df12 %>%
  mutate(across(c(
    employment_status, marital_status, product_type, region, education,
    employment_type, profession, exposure_level
  ), as.factor))

# Convert to numeric safely

numeric_cols <- c(
  
  "age",
  "residence_years",
  "cooperation_length_years",
   "loan_amount",
   "off_balance_limit_usage",
  "delinquencies_12m",
   "repayment_pattern_score",
   "query_count",
  "exposure_level")




df12[numeric_cols] <- lapply(df12[numeric_cols], function(x) as.numeric(as.character(x)))

factor_cols <- c("employment_status", "marital_status", "product_type", "region",
                 "education", "employment_type", "profession", "product_mix")

df12[factor_cols] <- lapply(df12[factor_cols], as.factor)


# STEP 3: Assume a 'default_event' binary column exists for modeling (you can add it if needed)

# For demo, we simulate one if it's not there

if (!"default_event" %in% colnames(df12)) {
  set.seed(42)
  df12$default_event <- rbinom(nrow(df12), 1, 0.3)
}

# STEP 4: Fit the logistic regression model

model <- glm(default_event ~ . -customer_id, data = df12, family = binomial)

# STEP 4: Fit the logistic regression model (using fewer predictors)

model <- glm(default_event ~ age + income + employment_status + loan_amount + delinquencies_12m, data = df12, family = binomial)


# STEP 5: View model summary

#summary(model)

# STEP 6: Predict PD for the first customer

pd_customer_1 <- predict(model, newdata = df12[1, ], type = "response")

pd_customer_all <- predict(model, newdata = df12[, ], type = "response")

# Predict PDs for ALL customers

df12$predicted_PD12 <- predict(model, newdata = df12, type = "response")

cat("Predicted PD for Customer 1:", round(pd_customer_1, 4), "\n")

#----------------------------------------------------------------------------------------------

#                            New Data added

#----------------------------------------------------------------------------------------------

df$initial_PD <- df$predicted_PD

# Calculate ratio or difference

df12$pd_ratio <- df12$predicted_PD12 / df$initial_PD

df12$pd_change <- df12$predicted_PD12 - df$initial_PD

df12$stage <- case_when(
  df12$delinquencies_12m >= 3 ~ 3,               # Stage 3: default
  df12$pd_ratio > 2 ~ 2,           # Stage 2: SICR
  TRUE ~ 1                      # Stage 1: performing
)


# Summary

table(df12$stage)
# >> # Load necessary libraries--------------  ECL STAGE PERFORMANCE GRAPH---------------------------------------------------------------
# install.packages("ggplot2")
# install.packages("dplyr")
# install.packages("tidyr")
# library(ggplot2)
# library(dplyr)
# library(tidyr)

# 1. Create actual stage distribution
stage_perf <- df12 %>%
  group_by(stage) %>%
  summarise(count = n()) %>%
  mutate(
    stage = paste0("Stage ", stage),
    current_perc = round((count / sum(count)) * 100, 1)
  )

# 2. Define target map as named vector
target_map <- c("Stage 1" = 90, "Stage 2" = 70, "Stage 3" = 40)
stage_perf$target_perc <- target_map[stage_perf$stage]


# 3. Reshape to long format for ggplot
plot_data <- stage_perf %>%
  select(stage, current_perc, target_perc) %>%
  pivot_longer(cols = c(current_perc, target_perc),
               names_to = "Metric",
               values_to = "Percentage") %>%
  mutate(Metric = recode(Metric = case_when(
    Metric == "current_perc" ~ "Current (%)",
    Metric == "target_perc" ~ "Target (%)",
    TRUE ~ as.character(Metric)
)))

# 4. Plot
ggplot(plot_data, aes(x = stage, y = Percentage, fill = Metric)) +
  geom_bar(stat = "identity", position = "dodge", width = 0.6) +
  labs(title = "ECL Stage Performance",
       x = NULL,
       y = "Percentage") +
  scale_fill_manual(values = c("Current (%)" = "mediumseagreen",
                               "Target (%)" = "royalblue")) +
  theme_minimal() +
  theme(text = element_text(size = 12))

# Export to Excel
#install.packages("openxlsx")
#library(openxlsx)

write.xlsx(df12, file.path(output_dir, "2.0Updated_dataset_after_12_months.xlsx"))

################################ THIRD CODE ##################################################################


# ASSUMPTIONS
LGD <- 0.45                 # Fixed LGD
lifetime_PD_multiplier <- 2.5  # You may calibrate this
# STEP 1: Calculate EAD
df12 <- df12 %>%
  mutate(
    EAD = loan_amount + (off_balance_limit_usage * loan_amount)
  )

# STEP 2: Assign lifetime PD based on stage
df12 <- df12 %>%
  mutate(
    lifetime_PD = ifelse(stage == 1,
                         predicted_PD12,
                         pmin(predicted_PD12 * lifetime_PD_multiplier, 1))
  )

# STEP 3: Calculate ECL using lifetime PD for all stages
df12 <- df12 %>%
  mutate(
    ECL = lifetime_PD * LGD * EAD
  )

# STEP 4: Summary of total ECL by stage
summary_ECL <- df12 %>%
  group_by(stage) %>%
  summarise(total_ECL = sum(ECL, na.rm = TRUE),
            avg_PD = mean(lifetime_PD, na.rm = TRUE),
            avg_EAD = mean(EAD, na.rm = TRUE),
            count = n())

#print(summary_ECL)

# STEP 5: Optional export
 write.xlsx(df12, file.path(output_dir,"updated_dataset_with_stage_ECL.xlsx"))

 #write summary_ECL in a separate excel i.e write.xlsx
write.xlsx(summary_ECL, file.path(output_dir,"summaryECL"))


##########################################################################################################



#change the df_12m to just df12 >> # Load required libraries
# library(dplyr)
# library(ggplot2)
# install.packages("waterfalls")
# library(waterfalls)
#--------------------------------------------------------------------------
# STEP 1: Add stage1_ECL
df12 <- df12 %>%
  mutate(stage1_ECL = predicted_PD12 * EAD)

# STEP 1.1: Simulate ECL changes (if real drivers are not available)
df12 <- df12 %>%
  mutate(
    ecl_change = ECL - stage1_ECL
  )


#--------------------------------------------------------------------------------------
library(ggplot2)
library(dplyr)

# Step 1: Define the input data
summary_waterfall <- data.frame(
  category = c("Opening ECL", "Volume Change", "PD Movement", "Stage Migration", "Closing ECL"),
  amount = c(778898, 116835, 194724, 233669, 352114)
)

# Step 2: Add cumulative waterfall logic
summary_waterfall <- summary_waterfall %>%
  mutate(
    id = row_number(),
    start = c(0, cumsum(amount)[-length(amount)]),
    end = cumsum(amount),
    label_pos = ifelse(amount >= 0, end, start)
  )

# Step 3: Add total bar (Net Change)
net_change <- data.frame(
  category = "Net Change",
  amount = sum(summary_waterfall$amount),
  id = nrow(summary_waterfall) + 1,
  start = 0,
  end = sum(summary_waterfall$amount),
  label_pos = sum(summary_waterfall$amount)
)

summary_waterfall <- bind_rows(summary_waterfall, net_change)

# Step 4: Define custom fill colors exactly as in the second screenshot
custom_colors <- c(
  "Opening ECL"     = "#3C78D8",  # Blue
  "Volume Change"   = "#F1C232",  # Yellow
  "PD Movement"     = "#6AA84F",  # Green
  "Stage Migration" = "#CC0000",  # Red
  "Closing ECL"     = "#3C78D8",  # Blue
  "Net Change"      = "#000000"   # Black
)


# Step 5: Plot
ggplot(summary_waterfall, aes(x = factor(category, levels = category))) +
  geom_rect(aes(
    xmin = id - 0.4, xmax = id + 0.4,
    ymin = start, ymax = end,
    fill = category
  ),
  color = NA) +  # <- this removes black bar outlines
  geom_text(aes(x = id, y = label_pos, label = round(amount, 0)),
            vjust = -0.5, size = 4, color = "black") +
  scale_fill_manual(values = custom_colors) +
  labs(title = "ECL Movement Waterfall Chart", x = NULL, y = NULL) +
  theme_minimal() +
  theme(
    panel.grid       = element_blank(),
    panel.border     = element_blank(),
    axis.ticks       = element_blank(),
    axis.line        = element_blank(),
    axis.text.y      = element_blank(),
    plot.background  = element_rect(fill = "white", color = NA),
    panel.background = element_rect(fill = "white", color = NA),
    legend.position  = "none"
  )


#######################################################################################################################################################################
#                               4th CODE
#######################################################################################################################################################################
#use this one...# Required packages
#library(readxl)
#library(dplyr)
#library(openxlsx)

# STEP 1: Load the credit dataset
df12macro <- read_excel(credit_input)

# STEP 2: Convert factors and numeric columns
df12macro <- df12macro %>%
  mutate(across(c(
    employment_status, marital_status, product_type, region, education,
    employment_type, profession, exposure_level
  ), as.factor))

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

df12macro[numeric_cols] <- lapply(df12macro[numeric_cols], function(x) as.numeric(as.character(x)))

# STEP 3: Create/simulate default_event if missing
if (!"default_event" %in% colnames(df12macro)) {
  set.seed(42)
  df12macro$default_event <- rbinom(nrow(df12macro), 1, 0.1)
}

# STEP 4: Load macroeconomic scenarios
scenarios <- read_excel(scenarios_input)

# STEP 5: Train logistic regression model

model <- glm(default_event ~ age + income + employment_status + 
               loan_amount + delinquencies_12m + gdp_growth + unemployment_rate,
             data = df12macro %>%
               mutate(gdp_growth = mean(scenarios$gdp_growth),
                      unemployment_rate = mean(scenarios$unemployment_rate)),  # Placeholder for training
             family = binomial)

# STEP 6: Predict under each scenario


predicted_list <- list()
for (i in 1:nrow(scenarios)) {
  scen <- scenarios[i, ]
  df_temp <- df
  df_temp$gdp_growth <- scen$gdp_growth
  df_temp$unemployment_rate <- scen$unemployment_rate
  predicted_list[[scen$scenario]] <- predict(model, newdata = df_temp, type = "response") * scen$weight
}
# Combine weighted predictions
df12macro$predicted_PD <- Reduce(`+`, predicted_list)



#11111111111111111111111111111111111111111111111111111111111111 TO BE CORRECTED   111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111


factor_cols <- c("employment_status", "marital_status", "product_type", "region",
                 "education", "employment_type", "profession", "product_mix")
df12macro[factor_cols] <- lapply(df12macro[factor_cols], as.factor)

# STEP 2: Prepare customer data
df12macro <- df12macro %>%
  mutate(across(c(employment_status, marital_status, product_type, region, education,
                  employment_type, profession, exposure_level), as.factor))

numeric_cols <- c("age", "residence_years", "cooperation_length_years", "loan_amount",
                  "off_balance_limit_usage", "delinquencies_12m", "repayment_pattern_score",
                  "query_count", "exposure_level")
df12macro[numeric_cols] <- lapply(df12macro[numeric_cols], function(x) as.numeric(as.character(x)))

factor_cols <- c("employment_status", "marital_status", "product_type", "region",
                 "education", "employment_type", "profession", "product_mix")
df12macro[factor_cols] <- lapply(df12macro[factor_cols], as.factor)


# STEP 3: Simulate default if missing
if (!"default_event" %in% colnames(df12macro)) {
  set.seed(42)
  df12macro$default_event <- rbinom(nrow(df12macro), 1, 0.3)
}

# STEP 4: Fit logistic model
model <- glm(default_event ~ age + income + employment_status + loan_amount + delinquencies_12m,
             data = df12macro, family = binomial)

# STEP 5: Predict 12-month PDs
df12macro$predicted_PD12 <- predict(model, newdata = df12macro, type = "response")


# --- STEP A: Baseline ECL (no macro overlay) ---
df12_baseline <- df12macro
df12_baseline$initial_PD <- df12_baseline$predicted_PD12 * runif(nrow(df12_baseline), 0.7, 1.3)

df12_baseline <- df12_baseline %>%
  mutate(
    EAD = loan_amount + (off_balance_limit_usage * loan_amount),
    PD_weighted = predicted_PD12,
    pd_ratio = PD_weighted / initial_PD,
    pd_change = PD_weighted - initial_PD,
    stage = case_when(
      delinquencies_12m >= 3 ~ 3,
      pd_ratio > 2 ~ 2,
      TRUE ~ 1
    ),
    lifetime_PD = ifelse(stage == 1, PD_weighted, pmin(PD_weighted * 2.5, 1)),
    ECL = lifetime_PD * 0.45 * EAD
  )

summary_ECL_baseline <- df12_baseline %>%
  group_by(stage) %>%
  summarise(
    total_ECL = sum(ECL, na.rm = TRUE),
    avg_PD = mean(lifetime_PD, na.rm = TRUE),
    avg_EAD = mean(EAD, na.rm = TRUE),
    count = n()
  )

# --- STEP B: Macro-adjusted ECL ---
df12_macro <- df12macro
df12_macro$initial_PD <- df12_macro$predicted_PD12 * runif(nrow(df12_macro), 0.7, 1.3)
# For baseline (less variance)
df12_baseline$initial_PD <- df12_baseline$predicted_PD12 * runif(nrow(df12_baseline), 0.9, 1.1)

# For macro (higher potential shock)
df12_macro$initial_PD <- df12_macro$predicted_PD12 * runif(nrow(df12_macro), 0.7, 1.3)

# Load economic scenarios
scenarios <- read_excel(scenarios_input)
base_gdp <- scenarios$gdp_growth[scenarios$scenario == "base"]

scenarios <- scenarios %>%
  mutate(adjustment = 1 + (base_gdp - gdp_growth) * 0.1)

# Scenario-adjusted PDs
for (i in 1:nrow(scenarios)) {
  scen <- scenarios$scenario[i]
  adj_factor <- scenarios$adjustment[i]
  df12_macro[[paste0("PD_", scen)]] <- pmin(df12_macro$predicted_PD12 * adj_factor, 1)
}

# Weighted average PD
df12_macro$PD_weighted <- 0
for (i in 1:nrow(scenarios)) {
  scen <- scenarios$scenario[i]
  weight <- scenarios$weight[i]
  df12_macro$PD_weighted <- df12_macro$PD_weighted + weight * df12_macro[[paste0("PD_", scen)]]
}

# Final ECL with macro overlay
df12_macro <- df12_macro %>%
  mutate(
    EAD = loan_amount + (off_balance_limit_usage * loan_amount),
    pd_ratio = PD_weighted / initial_PD,
    pd_change = PD_weighted - initial_PD,
    stage = case_when(
      delinquencies_12m >= 3 ~ 3,
      pd_ratio > 2 ~ 2,
      TRUE ~ 1
    ),
    lifetime_PD = ifelse(stage == 1, PD_weighted, pmin(PD_weighted * 2.5, 1)),
    ECL = lifetime_PD * 0.45 * EAD
  )

summary_ECL_macro <- df12_macro %>%
  group_by(stage) %>%
  summarise(
    total_ECL = sum(ECL, na.rm = TRUE),
    avg_PD = mean(lifetime_PD, na.rm = TRUE),
    avg_EAD = mean(EAD, na.rm = TRUE),
    count = n()
  )

# --- STEP C: Compare and Plot ---
summary_ECL$Scenario <- "Without Macro Overlay"
summary_ECL_macro$Scenario <- "With Macro Overlay"

df_plot <- bind_rows(summary_ECL, summary_ECL_macro) %>%
  select(stage, total_ECL, Scenario)

ggplot(df_plot, aes(x = factor(stage), y = total_ECL, fill = Scenario)) +
  geom_bar(stat = "identity", position = "dodge") +
  labs(
    title = "Comparison of ECL by Stage",
    x = "Stage",
    y = "Total Expected Credit Loss (ECL)"
  ) +
  theme_minimal() +
  scale_fill_manual(values = c("steelblue", "darkorange"))

# Optional: export results
write.xlsx(df12_macro,file.path(output_dir,"updated_dataset_with_macro_adjusted_ECL.xlsx"))
write.xlsx(summary_ECL_macro,file.path(output_dir, "summary_macro_adjusted_ECL.xlsx"))
write.xlsx(summary_ECL,file.path(output_dir,"summary_baseline_ECL.xlsx"))
write.xlsx(df12macro,file.path(output_dir,"stage1_ECL_with_macro_inputs.xlsx"))

#test this > # Load ggplot2 if not already loaded
  library(ggplot2)

# Scatter Plot: Loan Amount vs Income
ggplot(df12, aes(x = income, y = loan_amount)) +
  geom_point(color = "steelblue", alpha = 0.7, size = 2) +
  labs(title = "Loan Amount vs Income",
       x = "Income (BWP)",
       y = "Loan Amount (BWP)") +
  theme_minimal()
#111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111


############################################  5th CODE   ##############################################################

#                                         WAS CORRECTED, NOW DELETED
###################################################################################################################
#                                     6TH CODE
##################################################################################################################
# was also in correction

###############################################################################################################################
#                                                   7TH CODE
###############################################################################################################################

#library(openxlsx)

#library(dplyr)

# Create a new workbook

wb <- createWorkbook()

# ---- Stage Allocation Report ----

stage_allocation_report <- df12 %>%
  
  group_by(stage) %>%
  
  summarise(
    
    count = n(),
    
    avg_PD = mean(predicted_PD12, na.rm = TRUE),
    
    avg_EAD = mean(EAD, na.rm = TRUE)
    
  )

addWorksheet(wb, "Stage Allocation")

writeData(wb, "Stage Allocation", stage_allocation_report)

# ---- Loss Allowances Report ----

loss_allowances_report <- df12 %>%
  
  group_by(stage) %>%
  
  summarise(
    
    total_ECL = sum(ECL, na.rm = TRUE),
    
    avg_lifetime_PD = mean(lifetime_PD, na.rm = TRUE),
    
    avg_LGD = 0.45,  # fixed assumption
    
    total_EAD = sum(EAD, na.rm = TRUE)
    
  )

addWorksheet(wb, "Loss Allowances")

writeData(wb, "Loss Allowances", loss_allowances_report)

# ---- Credit Risk Exposure Report ----

credit_risk_exposure_report <- df12 %>%
  
  select(customer_id, stage, predicted_PD12, lifetime_PD, EAD, ECL)

addWorksheet(wb, "Credit Risk Exposure")

writeData(wb, "Credit Risk Exposure", credit_risk_exposure_report)

# ---- Save Workbook ----

saveWorkbook(wb, file.path(output_dir,"IFRS9_ECL_Report_Combined.xlsx") , overwrite = TRUE)

##############                                             ##################################
###########    6/15/2025 6:53 pm   "Average Income Distribution by Age Band"         #############################################

#Run > # Load necessary libraries
  
  library(dplyr)

library(ggplot2)

# STEP 1: Create Age Bands (you can adjust breaks as needed)

df12 <- df12 %>%
  
  mutate(age_band = cut(
    
    age,
    
    breaks = c(20, 30, 40, 50, 60, 70, 80),
    
    labels = c("20–29", "30–39", "40–49", "50–59", "60–69", "70–79"),
    
    right = FALSE
    
  ))

# STEP 2: Calculate average income by age band

income_by_band <- df12 %>%
  
  group_by(age_band) %>%
  
  summarise(avg_income = mean(income, na.rm = TRUE))

# STEP 3: Plot

ggplot(income_by_band, aes(x = age_band, y = avg_income)) +
  
  geom_col(fill = "cornflowerblue") +
  
  labs(title = "Average Income Distribution by Age Band",
       
       x = "Age Band",
       
       y = "Average Income (BWP)") +
  
  theme_minimal() +
  
  theme(text = element_text(size = 12))

#################    "Total Loan Volume by Age Band"  7:21 pm          ##################################

# Load required packages
library(dplyr)
library(ggplot2)

# STEP 1: Create age bands
df12 <- df12 %>%
  mutate(age_band = cut(
    age,
    breaks = c(20, 30, 40, 50, 60, 70, 80),
    labels = c("20–29", "30–39", "40–49", "50–59", "60–69", "70–79"),
    right = FALSE
  ))

# STEP 2: Summarize total loan volume by age band
loan_by_age_band <- df12 %>%
  group_by(age_band) %>%
  summarise(total_loan_amount = sum(loan_amount, na.rm = TRUE))

# STEP 3: Plot total loan volume
ggplot(loan_by_age_band, aes(x = age_band, y = total_loan_amount)) +
  geom_col(fill = "steelblue") +
  labs(title = "Total Loan Volume by Age Band",
       x = "Age Band",
       y = "Total Loan Amount (BWP)") +
  theme_minimal() +
  theme(text = element_text(size = 12))

#------------------   17/6/2025 08:00  Loan stages Breakdown  ---------------------------------------------------------------------

# Load required libraries

library(ggplot2)

library(dplyr)

# Step 1: Summarise counts per stage

stage_counts <- df12 %>%
  
  group_by(stage) %>%
  
  summarise(count = n()) %>%
  
  mutate(stage = factor(stage, levels = c(1, 2, 3),
                        
                        labels = c("Stage 1", "Stage 2", "Stage 3")))

# Step 2: Plot the bar chart

ggplot(stage_counts, aes(x = stage, y = count, fill = stage)) +
  
  geom_col(width = 0.6) +
  
  labs(title = "Loan Stages Breakdown",
       
       x = NULL, y = NULL) +
  
  scale_fill_manual(values = c("Stage 1" = "#5B9BD5",  # Blue
                               
                               "Stage 2" = "#00B386",  # Green
                               
                               "Stage 3" = "#4DC3D9")) +  # Teal
  
  theme_minimal() +
  
  theme(legend.position = "none",
        
        text = element_text(size = 12))

#-----------------   Diamond Stress ----------------------------

# Load required packages

library(dplyr)

# -------------------------------------------------

# STEP 1: Define Diamond Stress Scenario Parameters

# -------------------------------------------------

diamond_stress <- list(
  
  pd_multiplier = 2.0,              # PD doubles under diamond export shock
  
  lgd_stressed = 0.50,              # LGD increases from 45% to 50%
  
  ead_drawdown_factor = 1.10        # Off-balance usage increases by 10%
  
)

# -------------------------------------------------

# STEP 2: Apply Diamond Stress Adjustments to Data

# -------------------------------------------------

df12 <- df12 %>%
  
  mutate(
    
    diamond_stress_PD = pmin(predicted_PD12 * diamond_stress$pd_multiplier, 1),
    
    diamond_stress_LGD = diamond_stress$lgd_stressed,
    
    diamond_stress_EAD = loan_amount + (off_balance_limit_usage * loan_amount * diamond_stress$ead_drawdown_factor),
    
    diamond_stress_ECL = diamond_stress_PD * diamond_stress_LGD * diamond_stress_EAD
    
  )

# -------------------------------------------------

# STEP 3: Compare Baseline vs Diamond Stress ECL

diamond_ecl_summary <- df12 %>%
  
  group_by(stage) %>%
  
  summarise(
    
    base_ECL = sum(predicted_PD12 * 0.45 * (loan_amount + (off_balance_limit_usage * loan_amount)), na.rm = TRUE),
    
    diamond_stress_ECL = sum(diamond_stress_ECL, na.rm = TRUE),
    
    impact = diamond_stress_ECL - base_ECL,
    
    impact_pct = round((diamond_stress_ECL - base_ECL) / base_ECL * 100, 1),
    
    .groups = "drop"
    
  )

# STEP 4: Output Summary

print(diamond_ecl_summary)

library(ggplot2)
library(dplyr)

# Convert to long format for plotting
df_plot <- diamond_ecl_summary %>%
  select(stage, base_ECL, diamond_stress_ECL) %>%
  rename(`Base ECL` = base_ECL, `Diamond Stress ECL` = diamond_stress_ECL) %>%
  pivot_longer(cols = c(`Base ECL`, `Diamond Stress ECL`), names_to = "Scenario", values_to = "ECL")

# Plot
ggplot(df_plot, aes(x = factor(stage), y = ECL, fill = Scenario)) +
  geom_bar(stat = "identity", position = "dodge", width = 0.6) +
  geom_text(aes(label = round(ECL, 0)), position = position_dodge(width = 0.6), vjust = -0.5, size = 3) +
  labs(
    title = "ECL Comparison by Stage: Base vs Diamond Stress Scenario",
    x = "Stage",
    y = "Expected Credit Loss (ECL)"
  ) +
  scale_fill_manual(values = c("Base ECL" = "steelblue", "Diamond Stress ECL" = "darkorange")) +
  theme_minimal()
# -----------------------------------------------------

#     Distribution of PIT PDs

# -----------------------------------------------------

library(dplyr)

library(ggplot2)

# -----------------------------------------------------

# STEP 1: Prepare the Data

# Select relevant columns and drop missing values

df_pit <- df12 %>%
  
  select(default_event, age, income, loan_amount,
         
         credit_score, employment_duration_years,
         
         repayment_pattern_score, off_balance_limit_usage) %>%
  
  na.omit()

# Confirm binary target

table(df_pit$default_event)

# -----------------------------------------------------

# STEP 2: Fit the PIT Logistic Regression Model

# -----------------------------------------------------

pit_model <- glm(default_event ~ age + income + loan_amount +
                   
                   credit_score + employment_duration_years +
                   
                   repayment_pattern_score,
                 
                 data = df_pit,
                 
                 family = binomial)

# View model summary

summary(pit_model)

# -----------------------------------------------------

# STEP 3: Predict PIT PDs for Full Dataset

# -----------------------------------------------------

# Ensure variables exist in full dataset

df12 <- df12 %>%
  
  mutate(across(c(age, income, loan_amount, credit_score,
                  
                  employment_duration_years, repayment_pattern_score,
                  
                  off_balance_limit_usage), as.numeric)) %>%
  
  mutate(PIT_PD = predict(pit_model, newdata = df12, type = "response"))

# -----------------------------------------------------

# STEP 4: PIT ECL Calculation

# -----------------------------------------------------

# Define LGD (can be dynamic later)

LGD <- 0.45

# Calculate EAD (exposure at default)

df12 <- df12 %>%
  
  mutate(EAD = loan_amount + (off_balance_limit_usage * loan_amount),
         
         PIT_ECL = PIT_PD * LGD * EAD)

# -----------------------------------------------------

# STEP 5: Summary Output

# -----------------------------------------------------

# Preview PIT PDs and ECLs

head(df12 %>% select(PIT_PD, EAD, PIT_ECL))

# Total PIT ECL

total_pit_ecl <- sum(df12$PIT_ECL, na.rm = TRUE)

cat("Total PIT ECL for Portfolio:", round(total_pit_ecl, 2), "\n")

# -----------------------------------------------------

# STEP 6: Optional Visualization

# -----------------------------------------------------

ggplot(df12, aes(x = PIT_PD)) +
  
  geom_histogram(fill = "steelblue", bins = 40) +
  
  labs(title = "Distribution of PIT PDs", x = "PIT PD", y = "Count") +
  
  theme_minimal()


###############################################################################################################
##########################################################################################################
#             12:22 17/6/25

# -----------------------------------------

# STEP 1: Load Libraries and Data

# -----------------------------------------

# library(readxl)
# library(dplyr)
# install.packages("survival")
# install.packages("data.table")
# install.packages("survminer")
# library(survival)
# library(survminer)

# Load your dataset (update path as needed)

df <- read_excel(updated_input)


# STEP 2: Prepare Data for Survival Analysis

# Assume 'default_event' and 'months_on_book' exist or need to be created

# If you do not have 'months_on_book', we simulate it based on account_age_months

df <- df %>%
  
  mutate(
    
    default_event = as.integer(default_event),  # Ensure it's binary
    
    months_on_book = account_age_months,        # Use account age as exposure time
    
    event_occurred = default_event              # Alias for clarity
    
  ) %>%
  
  filter(!is.na(months_on_book))

# -----------------------------------------

# STEP 3: Fit Kaplan-Meier Survival Model

# -----------------------------------------

km_fit <- survfit(Surv(months_on_book, event_occurred) ~ 1, data = df)

# -----------------------------------------

# STEP 4: Plot the Survival Curve

# -----------------------------------------

ggsurvplot(
  
  km_fit, conf.int = TRUE, risk.table = TRUE,
  
  title = "Survival Curve – Time to Default",
  
  xlab = "Months on Book", ylab = "Survival Probability"
  
)

# -----------------------------------------

# STEP 5: Calculate Lifetime PDs at Specific Horizons

# -----------------------------------------

# Example horizons: 12, 24, 36 months

km_summary <- summary(km_fit, times = c(12, 24, 36))

lifetime_pd_table <- data.frame(
  
  Horizon_Months = km_summary$time,
  
  Survival_Probability = round(km_summary$surv, 4),
  
  Cumulative_PD = round(1 - km_summary$surv, 4)
  
)

print(lifetime_pd_table)

#---------------------------------                  -----------------------------------------
#   run this > 
dfEd <- df %>%
mutate(
  default_event = as.integer(default_event),  # Ensure it's binary
  months_on_book = account_age_months,        # Use account age as exposure time
  event_occurred = default_event              # Alias for clarity
) %>%
  filter(!is.na(months_on_book))



#####################################################################################
#                             2:38 pm
############################           ###############################################

# -----------------------------------------

# STEP 1: Load Libraries and Data

# -----------------------------------------

library(readxl)

library(dplyr)

library(survival)

library(survminer)

# Load data

df <- read_excel(updated_input)

# -----------------------------------------

# STEP 2: Prepare for Survival Analysis

# -----------------------------------------

df <- df %>%
  
  mutate(
    
    default_event = as.integer(default_event),     # Ensure binary format
    
    months_on_book = account_age_months,           # Use existing exposure
    
    event_occurred = default_event
    
  ) %>%
  
  filter(!is.na(months_on_book))

# -----------------------------------------

# STEP 3: Fit Kaplan-Meier Model

# -----------------------------------------

km_fit <- survfit(Surv(months_on_book, event_occurred) ~ 1, data = df)

# Optional: Plot

# ggsurvplot(km_fit, conf.int = TRUE, risk.table = TRUE)

# -----------------------------------------

# STEP 4: Extract Cumulative PDs at Horizons

# -----------------------------------------

km_summary <- summary(km_fit, times = c(12, 24, 36))

# Create a lookup table

survival_lookup <- data.frame(
  
  months = km_summary$time,
  
  lifetime_PD = round(1 - km_summary$surv, 4)
  
)

print(survival_lookup)

# -----------------------------------------

# STEP 5: Assign Lifetime PDs to Accounts

# -----------------------------------------

# Let's assume we're calculating ECL over a 24-month horizon

# (You can also match the horizon to remaining loan term)

selected_pd <- survival_lookup %>% filter(months == 24) %>% pull(lifetime_PD)

LGD <- 0.45

df <- df %>%
  
  mutate(
    
    EAD = loan_amount + (off_balance_limit_usage * loan_amount),
    
    survival_PD_24m = selected_pd,
    
    ECL_survival = survival_PD_24m * LGD * EAD
    
  )

# -----------------------------------------

# STEP 6: Portfolio-Level Summary

# -----------------------------------------

total_ecl <- sum(df$ECL_survival, na.rm = TRUE)

cat("Total Survival-Based ECL (24M horizon):", round(total_ecl, 2), "\n")

# Optional: Export to Excel

library(openxlsx)

 write.xlsx(df,file.path(output_dir, "Survival_ECL_Output.xlsx"))

output_dir <- "output"
if (!dir.exists(output_dir)) dir.create(output_dir, recursive = TRUE)

# 1. ECL Stage Performance
p_stage_perf <- ggplot(plot_data, aes(x = stage, y = Percentage, fill = Metric)) +
  geom_bar(stat = "identity", position = "dodge", width = 0.6) +
  labs(title = "ECL Stage Performance", x = NULL, y = "Percentage") +
  scale_fill_manual(values = c("Current (%)" = "mediumseagreen", "Target (%)" = "royalblue")) +
  theme_minimal() +
  theme(text = element_text(size = 12))
ggsave(file.path(output_dir, "ecl_stage_performance.png"), plot = p_stage_perf, width = 8, height = 6)

# 2. Average Income Distribution by Age Band
p_income <- ggplot(income_by_band, aes(x = age_band, y = avg_income)) +
  geom_col(fill = "cornflowerblue") +
  labs(title = "Average Income Distribution by Age Band", x = "Age Band", y = "Average Income (BWP)") +
  theme_minimal() +
  theme(text = element_text(size = 12))
ggsave(file.path(output_dir, "income_by_age_band.png"), plot = p_income, width = 8, height = 6)

# 3. Total Loan Volume by Age Band
p_loan <- ggplot(loan_by_age_band, aes(x = age_band, y = total_loan_amount)) +
  geom_col(fill = "steelblue") +
  labs(title = "Total Loan Volume by Age Band", x = "Age Band", y = "Total Loan Amount (BWP)") +
  theme_minimal() +
  theme(text = element_text(size = 12))
ggsave(file.path(output_dir, "loan_volume_by_age.png"), plot = p_loan, width = 8, height = 6)

# 4. Loan Stages Breakdown
p_stage_breakdown <- ggplot(stage_counts, aes(x = stage, y = count, fill = stage)) +
  geom_col(width = 0.6) +
  labs(title = "Loan Stages Breakdown", x = NULL, y = NULL) +
  scale_fill_manual(values = c("Stage 1" = "#5B9BD5", "Stage 2" = "#00B386", "Stage 3" = "#4DC3D9")) +
  theme_minimal() +
  theme(legend.position = "none", text = element_text(size = 12))
ggsave(file.path(output_dir, "stage_breakdown.png"), plot = p_stage_breakdown, width = 8, height = 6)

# 5. Diamond Stress ECL Comparison
p_diamond <- ggplot(df_plot, aes(x = factor(stage), y = ECL, fill = Scenario)) +
  geom_bar(stat = "identity", position = "dodge", width = 0.6) +
  geom_text(aes(label = round(ECL, 0)), position = position_dodge(width = 0.6), vjust = -0.5, size = 3) +
  labs(title = "ECL Comparison by Stage: Base vs Diamond Stress Scenario", x = "Stage", y = "Expected Credit Loss (ECL)") +
  scale_fill_manual(values = c("Base ECL" = "steelblue", "Diamond Stress ECL" = "darkorange")) +
  theme_minimal()
ggsave(file.path(output_dir, "diamond_stress_comparison.png"), plot = p_diamond, width = 10, height = 6)

# 6. Distribution of PIT PDs
p_pit <- ggplot(df12, aes(x = PIT_PD)) +
  geom_histogram(fill = "steelblue", bins = 40) +
  labs(title = "Distribution of PIT PDs", x = "PIT PD", y = "Count") +
  theme_minimal()
ggsave(file.path(output_dir, "pit_pd_distribution.png"), plot = p_pit, width = 8, height = 6)

# 7. ECL Movement Waterfall Chart
p_waterfall <- ggplot(summary_waterfall, aes(x = factor(category, levels = category))) +
  geom_rect(aes(
    xmin = id - 0.4, xmax = id + 0.4,
    ymin = start, ymax = end,
    fill = category
  ), color = NA) +
  geom_text(aes(x = id, y = label_pos, label = round(amount, 0)),
            vjust = -0.5, size = 4, color = "black") +
  scale_fill_manual(values = custom_colors) +
  labs(title = "ECL Movement Waterfall Chart", x = NULL, y = NULL) +
  theme_minimal() +
  theme(
    panel.grid       = element_blank(),
    panel.border     = element_blank(),
    axis.ticks       = element_blank(),
    axis.line        = element_blank(),
    axis.text.y      = element_blank(),
    plot.background  = element_rect(fill = "white", color = NA),
    panel.background = element_rect(fill = "white", color = NA),
    legend.position  = "none"
  )
ggsave(file.path(output_dir, "ecl_movement_waterfall.png"), plot = p_waterfall, width = 10, height = 6)

# 8. Survival Curve – Time to Default (if using survminer)
# Only if you have ggsurvplot and km_fit
# surv_plot <- ggsurvplot(
#   km_fit, conf.int = TRUE, risk.table = TRUE,
#   title = "Survival Curve – Time to Default",
#   xlab = "Months on Book", ylab = "Survival Probability"
# )
# ggsave(file.path(output_dir, "survival_curve.png"), plot = surv_plot$plot, width = 8, height = 6)




# Print completion message
cat("Analysis complete! All outputs saved to the 'output' folder:\n")