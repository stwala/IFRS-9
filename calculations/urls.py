from django.urls import path
from .views import run_model_view, get_output_files

urlpatterns = [
    path('run/', run_model_view, name='run_model'),
    path('outputs/', get_output_files, name='get_output_files'),
]
