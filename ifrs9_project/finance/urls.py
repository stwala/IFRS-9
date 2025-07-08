from django.urls import path

from django.contrib import admin
from .views import dashboard

urlpatterns = [
    path("", dashboard, name="dashboard"),
]

admin.site.site_header = 'IFRS9 Dashboard'
admin.site.site_title = 'iFRS9 Dashboard'
admin.site.index_title = 'IFRS9 admin'  