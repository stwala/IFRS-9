from django.contrib import admin

from django.contrib import admin
from .models import ModelRun, ModelScript

@admin.register(ModelScript)
class ModelScriptAdmin(admin.ModelAdmin):
    list_display = ['name', 'script_file']


@admin.register(ModelRun)
class ModelRunAdmin(admin.ModelAdmin):
    list_display = ['script', 'run_date', 'status', 'created_at']
    list_filter = ['status', 'run_date']
    search_fields = ['script__name']

