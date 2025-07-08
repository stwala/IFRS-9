from django.db import models

class GDP(models.Model):
    year = models.PositiveIntegerField()
    nominal = models.PositiveIntegerField()
    real = models.PositiveIntegerField()
    

    def __str__(self):
        return f"in {self.year} the nominal GDP was {self.nominal} and the real GDP was {self.real}"
    
    
class Unemployment(models.Model):
    year = models.PositiveIntegerField()
    unemployment = models.PositiveIntegerField()
    
    def __str__(self):
        return f"in {self.year} the unemployment rate was {self.unemployment}"
    
    
class Inflation(models.Model):
    year = models.PositiveIntegerField()
    inflation = models.PositiveIntegerField()
    
    def __str__(self):
        return f"in {self.year} the inflation rate was {self.inflation}"
       
    
class LogisticRegression(models.Model):
    image = models.ImageField(upload_to='logistic_regression_images/')
    description = models.TextField()

    def __str__(self):
        return self.description
    