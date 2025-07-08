from django.urls import path
from .views import *

urlpatterns = [
    path("", obligor_list, name="obligor_list"),
    path('', home, name='home'),
    # path("predict/", predict_ecl, name="predict_ecl"),
]
