from django.db import models

class FinancialInstrument(models.Model):
    CLASSIFICATION_CHOICES = [
        ('AC', 'Amortized Cost'),
        ('FVOCI', 'Fair Value OCI'),
        ('FVTPL', 'Fair Value P&L'),
    ]
    
    name = models.CharField(max_length=100)
    classification = models.CharField(max_length=10, choices=CLASSIFICATION_CHOICES)
    credit_rating = models.CharField(max_length=10)
    exposure = models.FloatField()
    ecl_stage = models.IntegerField(choices=[(1, 'Stage 1'), (2, 'Stage 2'), (3, 'Stage 3')])
    pd = models.FloatField()  # Probability of Default
    lgd = models.FloatField() # Loss Given Default
    ead = models.FloatField() # Exposure at Default

    def calculate_ecl(self):
        """Expected Credit Loss Calculation"""
        return self.pd * self.lgd * self.ead

    def __str__(self):
        return self.name
