# from django.shortcuts import render
# from .models import LoanData
# import matplotlib.pyplot as plt



# def loan_data_list(request):
#     loan_data = LoanData.objects.all()
#     return render(request, "loan_data_list.html", {"loan_data": loan_data})





# from django.shortcuts import render
# from django.http import JsonResponse


# def loan_analytics(request):
    
#     data = {
#         "ages": [45, 23, 56],
#         "incomes": [23334, 200000, 230000],
#         "loan_amounts": [344444, 234444, 210000],
#         "loan_statuses": [2, 1],
#         "loan_stages": [1, 1, 1]
#     }


#     return render(request, "loan_analytics.html", {"data": data})

from django.shortcuts import render
from obligor_data.models import Obligor
from collections import Counter
import json

def loan_analytics(request):
    obligors = Obligor.objects.all()

    if not obligors:
        return render(request, "loan_analytics.html", {"data": json.dumps({})})

    # Prepare lists
    ages = []
    incomes = []
    loan_amounts = []
    default_flags = []
    credit_lengths = []
    loan_statuses_raw = []

    for o in obligors:
        ages.append(o.person_age)
        incomes.append(float(o.person_income))
        loan_amounts.append(float(o.loan_amnt))
        credit_lengths.append(o.cb_person_cred_hist_length)
        default_flags.append(1 if o.cb_person_default_on_file else 0)
        loan_statuses_raw.append(o.loan_status)

    # Count loan statuses
    status_count = Counter(loan_statuses_raw)
    loan_statuses = [
        status_count.get("PAID_OFF", 0) + status_count.get("CURRENT", 0),  # Approved
        status_count.get("DEFAULT", 0) + status_count.get("LATE", 0)       # Rejected
    ]

    # Dummy stage assignment (can be replaced with a real model field)
    loan_stages = [0, 0, 0]
    for rate in [float(o.loan_int_rate) for o in obligors]:
        if rate <= 10:
            loan_stages[0] += 1  # Stage 1
        elif rate <= 20:
            loan_stages[1] += 1  # Stage 2
        else:
            loan_stages[2] += 1  # Stage 3

    data = {
        "ages": ages,
        "incomes": incomes,
        "loan_amounts": loan_amounts,
        "loan_statuses": loan_statuses,
        "loan_stages": loan_stages,
    }

    return render(request, "loan_analytics.html", {"data": json.dumps(data)})


from django.shortcuts import render
from obligor_data.models import Obligor  # Pull real data from the obligor app
import pandas as pd

def loan_data_list(request):
    obligors = Obligor.objects.all().values()

    if not obligors:
        return render(request, "loan_data_list.html", {"loan_summary": []})

    df = pd.DataFrame(obligors)

    # Calculate derived metrics
    df["debt_burden_ratio"] = df["loan_amnt"] / df["person_income"]

    # Group and summarize by loan grade
    summary = df.groupby("loan_grade").agg({
        "loan_amnt": "mean",
        "loan_int_rate": "mean",
        "person_age": "mean",
        "person_emp_length": "mean",
        "cb_person_cred_hist_length": "mean",
        "cb_person_default_on_file": "mean",
        "debt_burden_ratio": "mean",
        "loan_grade": "count",
    }).rename(columns={
        "loan_amnt": "avg_loan_amount",
        "loan_int_rate": "avg_interest_rate",
        "person_age": "avg_age",
        "person_emp_length": "avg_employment_years",
        "cb_person_cred_hist_length": "avg_credit_history_years",
        "cb_person_default_on_file": "default_rate",
        "debt_burden_ratio": "avg_debt_burden_ratio",
        "loan_grade": "number_of_loans"
    }).reset_index()

    summary["default_rate_percent"] = summary["default_rate"] * 100
    summary.drop(columns="default_rate", inplace=True)

    loan_summary = summary.to_dict(orient="records")
    return render(request, "loan_data_list.html", {"loan_summary": loan_summary})

def landing(request):
    return render(request, 'homepage/landing.html')
def home(request):
    return render(request, 'home.html')