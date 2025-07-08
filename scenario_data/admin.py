from django.contrib import admin
from .models import GDP, Unemployment, Inflation, LogisticRegression

@admin.register(GDP)
class GDPAdmin(admin.ModelAdmin):
    list_display = ('year', 'nominal', 'real')
    search_fields = ('year',)

@admin.register(Unemployment)
class UnemploymentAdmin(admin.ModelAdmin):
    list_display = ('year', 'unemployment')
    search_fields = ('year',)

@admin.register(Inflation)
class InflationAdmin(admin.ModelAdmin):
    list_display = ('year', 'inflation')
    search_fields = ('year',)

@admin.register(LogisticRegression)
class LogisticRegressionAdmin(admin.ModelAdmin):
    list_display = ('description', 'image')
    search_fields = ('description',)