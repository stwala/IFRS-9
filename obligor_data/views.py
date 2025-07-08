from django.shortcuts import render
from .models import Obligor
from django.shortcuts import render

def obligor_list(request):
    obligors = Obligor.objects.all()
    return render(request, "obligor_list.html", {"obligors": obligors})
def logistic_regression_detail(request):
    return render(request, 'logistic_regression_images/logistic_regression_detail.html')


def home(request):
    return render(request, 'home.html')


def neural_networks_view(request):
    return render(request, 'neural_networks.html')

def factor_models_view(request):
    return render(request, 'factor_models.html')

def stage1_view(request):
    return render(request, 'stage1.html')

def stage2_view(request):
    return render(request, 'stage2.html')

def stage3_view(request):
    return render(request, 'stage3.html')



def landing_page(request):
    return render(request, 'landing_home.html')