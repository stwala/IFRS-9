# Generated by Django 5.2 on 2025-06-23 17:24

import django.db.models.deletion
from django.db import migrations, models


class Migration(migrations.Migration):

    initial = True

    dependencies = [
    ]

    operations = [
        migrations.CreateModel(
            name='ModelScript',
            fields=[
                ('id', models.BigAutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('name', models.CharField(max_length=100)),
                ('script_file', models.FileField(upload_to='scripts/')),
            ],
        ),
        migrations.CreateModel(
            name='ModelRun',
            fields=[
                ('id', models.BigAutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('input_file', models.FileField(upload_to='inputs/')),
                ('output_file', models.FileField(blank=True, null=True, upload_to='outputs/')),
                ('run_date', models.DateTimeField(auto_now_add=True)),
                ('PrevRun_Nr', models.DateField()),
                ('NBRun_Nr', models.DateField()),
                ('status', models.CharField(choices=[('PENDING', 'Pending'), ('RUNNING', 'Running'), ('SUCCESS', 'Success'), ('FAILED', 'Failed')], default='PENDING', max_length=20)),
                ('created_at', models.DateTimeField(auto_now_add=True)),
                ('script', models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, to='calculations.modelscript')),
            ],
        ),
    ]
