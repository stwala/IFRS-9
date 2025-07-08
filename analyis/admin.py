from django.contrib import admin
from .models import LoanData

@admin.register(LoanData)
class LoanDataAdmin(admin.ModelAdmin):
    list_display = ("person_age", "person_income", "loan_amnt", "loan_int_rate", "loan_status")
    list_filter = ("loan_status", "loan_grade", "loan_intent")
    search_fields = ("person_age", "person_income", "loan_amnt")

