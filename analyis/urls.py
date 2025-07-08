from django.urls import path
from .views import loan_data_list, loan_analytics

urlpatterns = [
    path("loan-data/", loan_data_list, name="loan_data_list"),
    path('analytics/', loan_analytics, name='loan_analytics'),
]
from django.contrib import admin
from django.urls import path, include
# from analyis.views import loan_analytics  # 👈 import your landing view

