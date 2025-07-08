# Helper function to install and load packages only if not already installed
packages <- c("readxl", "dplyr", "openxlsx")

for (pkg in packages) {
  if (!requireNamespace(pkg, quietly = TRUE)) {
    install.packages(pkg)
  }
  library(pkg, character.only = TRUE)
}

# STEP 1: Load the Excel file

# Replace 'your_file.xlsx' with your actual file path

df <- read_excel("C:/Users/NESK/Downloads/Extended_Customer_Credit_Dataset.xlsx")
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

summary(model)

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

#install.packages("openxlsx")

#library(openxlsx)

# Summary

#table(df$stage)

# Export to Excel

#write.xlsx(df, "updated_dataset_after_12_months.xlsx")



#############################################################===========================================================

# STEP 1: Load the Excel file

# Replace 'your_file.xlsx' with your actual file path

df12 <- read_excel("C:/Users/NESK/Downloads/Customer_Data_At_12_Months (1).xlsx")

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

summary(model)

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

#table(df12$stage)

# Export to Excel
install.packages("openxlsx")
library(openxlsx)

write.xlsx(df12, "calculations/Rscript/Output/IFRS9_outputs/Newest1updated_dataset_after_12_months.xlsx")


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

print(summary_ECL)

# STEP 5: Optional export
 write.xlsx(df12, "calculations/Rscript/Output/IFRS9_outputs/updated_dataset_with_stage_ECL.xlsx")

##########################################################################################################
cat("\nScript completed successfully!\n")








