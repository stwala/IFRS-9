from django.shortcuts import render
from .models import LoanData
import matplotlib.pyplot as plt



def loan_data_list(request):
    loan_data = LoanData.objects.all()
    return render(request, "loan_data_list.html", {"loan_data": loan_data})





from django.shortcuts import render
from django.http import JsonResponse


def loan_analytics(request):
    
    data = {
        "ages": [45, 23, 56],
        "incomes": [23334, 200000, 230000],
        "loan_amounts": [344444, 234444, 210000],
        "loan_statuses": [2, 1],
        "loan_stages": [1, 1, 1]
    }

    # 🎯 Pass data to template instead of returning JSON
    return render(request, "loan_analytics.html", {"data": data})


