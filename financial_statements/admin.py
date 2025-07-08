from django.contrib import admin
from django.urls import path
from django.utils.html import format_html
from django.shortcuts import redirect
from .models import (
    StatementOfIncome,
    StatementOfFinancialPosition,
    StatementOfChangesInEquity,
    StatementOfCashflow,
)

# ✅ Register the other models normally
admin.site.register(StatementOfFinancialPosition)
admin.site.register(StatementOfChangesInEquity)
admin.site.register(StatementOfCashflow)

# ✅ Custom admin for StatementOfIncome
class StatementOfIncomeAdmin(admin.ModelAdmin):
    list_display = ('name', 'uploaded_at')

   
# ✅ Register only once
admin.site.register(StatementOfIncome, StatementOfIncomeAdmin)
