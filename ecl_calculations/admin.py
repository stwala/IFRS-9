# ecl_calculations/admin.py
from django.contrib import admin
from .models import ECLReport, StageAllocationReport, LossAllowance, CreditRiskExposure

admin.site.register(ECLReport)
admin.site.register(StageAllocationReport)
admin.site.register(LossAllowance)
admin.site.register(CreditRiskExposure)
