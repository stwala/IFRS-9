
from django.shortcuts import render, get_object_or_404
import pandas as pd
from .models import (
    StatementOfIncome,
    StatementOfFinancialPosition,
    StatementOfChangesInEquity,
    StatementOfCashflow,
)

def financial_statements_finlanding(request):
    context = {
        "incomes": StatementOfIncome.objects.all(),
        "positions": StatementOfFinancialPosition.objects.all(),
        "equitys": StatementOfChangesInEquity.objects.all(),
        "cashflows": StatementOfCashflow.objects.all(),
    }
    return render(request, "finlanding.html", context)

def view_excel(request, statement_type, file_id):
    model_map = {
        'income': StatementOfIncome,
        'position': StatementOfFinancialPosition,
        'equity': StatementOfChangesInEquity,
        'cashflow': StatementOfCashflow,
    }

    model = model_map.get(statement_type)
    if not model:
        return render(request, 'financial_statements/error.html', {'message': 'Invalid statement type.'})

    file_obj = get_object_or_404(model, pk=file_id)

    try:
       df = pd.read_excel(file_obj.file.path)
       df = df.fillna('')
       table_html = df.to_html(classes='table table-bordered table-striped', index=False)

    except Exception as e:
        return render(request, 'financial_statements/error.html', {'message': f'Error reading file: {str(e)}'})

    return render(request, 'financial_statements/view_excel.html', {
        'file_name': file_obj.name,
        'table_html': table_html,
        'download_url': file_obj.file.url,
    })
