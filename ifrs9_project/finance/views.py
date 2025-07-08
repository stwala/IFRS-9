from django.shortcuts import render
from .models import FinancialInstrument

def dashboard(request):
    instruments = FinancialInstrument.objects.all()
    total_ecl = sum(i.calculate_ecl() for i in instruments)
    return render(request, "dashboard.html", {"instruments": instruments, "total_ecl": total_ecl})
