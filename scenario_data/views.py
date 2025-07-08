from django.shortcuts import render

from django.shortcuts import render, get_object_or_404
from .models import GDP, Unemployment, Inflation, LogisticRegression

# 🚀 Scenario Data Page
def scenario_data(request):
    return render(request, 'scenario_data.html')

# 📊 GDP Views
def gdp_list(request):
    gdp_data = GDP.objects.all().order_by('-year')
    return render(request, 'gdp_list.html', {'gdp_data': gdp_data})

# 📊 Unemployment Views
def unemployment_list(request):
    unemployment_data = Unemployment.objects.all().order_by('-year')
    return render(request, 'unemployment_list.html', {'unemployment_data': unemployment_data})

# 📊 Inflation Views
def inflation_list(request):
    inflation_data = Inflation.objects.all().order_by('-year')
    return render(request, 'inflation_list.html', {'inflation_data': inflation_data})

# 📊 Logistic Regression Model Views
from django.shortcuts import render

def logistic_regression_view(request):
    return render(request, 'logistic_regression_detail.html')
