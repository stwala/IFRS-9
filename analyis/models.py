from django.db import models

class LoanData(models.Model):
    HOME_OWNERSHIP_CHOICES = [
        (0, "Rent"),
        (1, "Own"),
        (2, "Mortgage"),
        (3, "Other"),
    ]

    LOAN_INTENT_CHOICES = [
        (0, "Debt Consolidation"),
        (1, "Education"),
        (2, "Home Improvement"),
        (3, "Medical"),
        (4, "Personal"),
        (5, "Venture"),
    ]

    LOAN_GRADE_CHOICES = [
        (1, "A"),
        (2, "B"),
        (3, "C"),
        (4, "D"),
        (5, "E"),
        (6, "F"),
        (7, "G"),
    ]

    LOAN_STATUS_CHOICES = [
        (0, "Approved"),
        (1, "Rejected"),
    ]

    person_age = models.PositiveIntegerField()
    person_income = models.PositiveIntegerField()
    person_home_ownership = models.IntegerField(choices=HOME_OWNERSHIP_CHOICES)
    person_emp_length = models.FloatField()
    loan_intent = models.IntegerField(choices=LOAN_INTENT_CHOICES)
    loan_grade = models.IntegerField(choices=LOAN_GRADE_CHOICES)
    loan_amnt = models.PositiveIntegerField()
    loan_int_rate = models.FloatField()
    loan_status = models.IntegerField(choices=LOAN_STATUS_CHOICES)
    loan_percent_income = models.FloatField()
    cb_person_default_on_file = models.BooleanField()
    cb_person_cred_hist_length = models.PositiveIntegerField()
    PD = models.FloatField()
    Stage = models.PositiveIntegerField()
    ECL = models.FloatField()
    ECL_Year_1 = models.FloatField(null=True, blank=True)
    ECL_Year_2 = models.FloatField(null=True, blank=True)
    ECL_Year_3 = models.FloatField(null=True, blank=True)

    def __str__(self):
        return f"Loan Data - Age: {self.person_age}, Loan Amount: {self.loan_amnt}"
