from django.db import models

class Obligor(models.Model):
    HOME_OWNERSHIP_CHOICES = [
        ('MORTGAGE', 'Mortgage'),
        ('RENT', 'Rent'),
        ('OWN', 'Own'),
        ('OTHER', 'Other'),
    ]

    LOAN_INTENT_CHOICES = [
        ('DEBT_CONSOLIDATION', 'Debt Consolidation'),
        ('EDUCATION', 'Education'),
        ('HOME_IMPROVEMENT', 'Home Improvement'),
        ('MEDICAL', 'Medical'),
        ('PERSONAL', 'Personal'),
        ('VENTURE', 'Venture'),
    ]

    LOAN_GRADE_CHOICES = [
        ('A', 'A'), ('B', 'B'), ('C', 'C'), ('D', 'D'),
        ('E', 'E'), ('F', 'F'), ('G', 'G')
    ]

    LOAN_STATUS_CHOICES = [
        ('CURRENT', 'Current'),
        ('DEFAULT', 'Default'),
        ('LATE', 'Late'),
        ('PAID_OFF', 'Paid Off'),
    ]

    person_age = models.PositiveIntegerField()
    person_income = models.DecimalField(max_digits=10, decimal_places=2)
    person_home_ownership = models.CharField(max_length=10, choices=HOME_OWNERSHIP_CHOICES)
    person_emp_length = models.PositiveIntegerField(help_text="Employment length in years")
    loan_intent = models.CharField(max_length=20, choices=LOAN_INTENT_CHOICES)
    loan_grade = models.CharField(max_length=1, choices=LOAN_GRADE_CHOICES)
    loan_amnt = models.DecimalField(max_digits=10, decimal_places=2)
    loan_int_rate = models.DecimalField(max_digits=5, decimal_places=2, help_text="Interest rate in %")
    loan_status = models.CharField(max_length=10, choices=LOAN_STATUS_CHOICES)
    loan_percent_income = models.DecimalField(max_digits=5, decimal_places=2, help_text="Loan as % of income")
    cb_person_default_on_file = models.BooleanField(help_text="Has the person defaulted before?")
    cb_person_cred_hist_length = models.PositiveIntegerField(help_text="Credit history length in years")

    def __str__(self):
        return f"{self.person_age} yrs | {self.loan_status} | {self.loan_amnt} BWP"

