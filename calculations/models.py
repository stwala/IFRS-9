from django.db import models

from django.db import models

class ModelScript(models.Model):
    name = models.CharField(max_length=100)
    script_file = models.FileField(upload_to='scripts/')

    def __str__(self):
        return self.name


class ModelRun(models.Model):
    STATUS_CHOICES = [ 
        ('PENDING', 'Pending'),
        ('RUNNING', 'Running'),
        ('SUCCESS', 'Success'),
        ('FAILED', 'Failed'),
    ]

    script = models.ForeignKey(ModelScript, on_delete=models.CASCADE)
    input_file = models.FileField(upload_to='inputs/')
    output_file = models.FileField(upload_to='outputs/', null=True, blank=True)
    run_date = models.DateTimeField(auto_now_add=True)
    PrevRun_Nr = models.DateField()
    NBRun_Nr = models.DateField()
    status = models.CharField(max_length=20, choices=STATUS_CHOICES, default='PENDING')
    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"{self.script.name} run on {self.run_date.strftime('%Y-%m-%d')}"
