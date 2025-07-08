from django.urls import path
from . import views

urlpatterns = [
    path('', views.financial_statements_finlanding, name='financial_statements_finlanding'),
     path('', views.financial_statements_finlanding, name='financial_statements_finlanding'),
    path('view/<str:statement_type>/<int:file_id>/', views.view_excel, name='view_excel'),
]
