from django.shortcuts import render
from .models import Obligor

def obligor_list(request):
    obligors = Obligor.objects.all()
    return render(request, "obligor_list.html", {"obligors": obligors})


def home(request):
    return render(request, 'home.html')



###models
# import joblib
# import numpy as np
# import pandas as pd
# from django.shortcuts import render
# from .models import Obligor


# import joblib
# import os


# # BASE_DIR = os.path.dirname(os.path.abspath(__file__))
# BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

# # Load trained models from the correct path
# model_path = os.path.join(BASE_DIR,  "pd_model.pkl")
# scaler_path = os.path.join(BASE_DIR, "scaler.pkl")

# model = joblib.load(model_path)
# scaler = joblib.load(scaler_path)




# # Load trained models
# # model = joblib.load("pd_model.pkl")  # Load logistic regression model
# # scaler = joblib.load("scaler.pkl")  # Load scaler

# # Constants for ECL calculation
# LGD = 0.45  # 45% Loss Given Default
# stage_1_threshold = 0.01
# stage_2_threshold = 0.05

# def predict_ecl(request):
#     if request.method == "POST":
#         # Get user inputs from form
#         person_age = float(request.POST.get("person_age"))
#         person_income = float(request.POST.get("person_income"))
#         person_home_ownership = float(request.POST.get("person_home_ownership"))
#         person_emp_length = float(request.POST.get("person_emp_length"))
#         loan_intent = float(request.POST.get("loan_intent"))
#         loan_grade = float(request.POST.get("loan_grade"))
#         loan_amnt = float(request.POST.get("loan_amnt"))
#         loan_int_rate = float(request.POST.get("loan_int_rate"))
#         loan_percent_income = float(request.POST.get("loan_percent_income"))
#         cb_person_default_on_file = float(request.POST.get("cb_person_default_on_file"))
#         cb_person_cred_hist_length = float(request.POST.get("cb_person_cred_hist_length"))

#         # Prepare input data
#         input_data = np.array([[person_age, person_income, person_home_ownership, person_emp_length, 
#                                 loan_intent, loan_grade, loan_amnt, loan_int_rate, loan_percent_income, 
#                                 cb_person_default_on_file, cb_person_cred_hist_length]])
        
#         # Scale input data
#         input_scaled = scaler.transform(input_data)

#         # Predict Probability of Default (PD)
#         pd_prediction = model.predict_proba(input_scaled)[0][1]  # Get probability of default

#         # Determine the stage
#         if pd_prediction <= stage_1_threshold:
#             stage = 1
#         elif pd_prediction <= stage_2_threshold:
#             stage = 2
#         else:
#             stage = 3

#         # Calculate Expected Credit Loss (ECL)
#         EAD = loan_amnt  # Exposure at Default
#         ECL = pd_prediction * LGD * EAD  # Base ECL calculation

#         # Adjust ECL based on stage
#         if stage == 1:
#             ECL = ECL * 1  # 12-month ECL
#         elif stage == 2:
#             ECL = ECL * 1.05  # Lifetime ECL
#         else:
#             ECL = ECL * 1.1025  # Lifetime ECL (Stage 3)

#         return render(request, "predict_result.html", {
#             "pd_prediction": round(pd_prediction, 4),
#             "stage": stage,
#             "ECL": round(ECL, 2)
#         })

#     return render(request, "predict_form.html")
