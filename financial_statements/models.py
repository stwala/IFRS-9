from django.db import models

class StatementOfIncome(models.Model):
    name = models.CharField(max_length=200)
    file = models.FileField(upload_to='financial_statements/income/')
    uploaded_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return self.name

class StatementOfFinancialPosition(models.Model):
    name = models.CharField(max_length=200)
    file = models.FileField(upload_to='financial_statements/position/')
    uploaded_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return self.name

class StatementOfChangesInEquity(models.Model):
    name = models.CharField(max_length=200)
    file = models.FileField(upload_to='financial_statements/equity/')
    uploaded_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return self.name

class StatementOfCashflow(models.Model):
    name = models.CharField(max_length=200)
    file = models.FileField(upload_to='financial_statements/cashflow/')
    uploaded_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return self.name
