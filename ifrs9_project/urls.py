"""ifrs9_project URL Configuration

The `urlpatterns` list routes URLs to views. For more information please see:
    https://docs.djangoproject.com/en/3.2/topics/http/urls/
Examples:
Function views
    1. Add an import:  from my_app import views
    2. Add a URL to urlpatterns:  path('', views.home, name='home')
Class-based views
    1. Add an import:  from other_app.views import Home
    2. Add a URL to urlpatterns:  path('', Home.as_view(), name='home')
Including another URLconf
    1. Import the include() function: from django.urls import include, path
    2. Add a URL to urlpatterns:  path('blog/', include('blog.urls'))
"""
from django.contrib import admin
from django.urls import path, include
from obligor_data.views import home,landing_page
from calculations import views as calculations_views  # Import your view
# from calculations.admin import admin_site



urlpatterns = [
    path('admin/', admin.site.urls),
    path('finance/', include('finance.urls')),
    path('obligor_data/', include('obligor_data.urls')),
    path('',landing_page, name='landing_home'),
    path('scenario/', include('scenario_data.urls')),
    path("analysis/", include("analyis.urls")),
    path('financial-statements/', include('financial_statements.urls')),
    path('ecl-calculations/', include('ecl_calculations.urls')),
    path('calculations/', include('calculations.urls')),
 


  

]
from django.urls import path, include
from django.conf import settings
from django.conf.urls.static import static



if settings.DEBUG:
    urlpatterns += static(settings.MEDIA_URL, document_root=settings.MEDIA_ROOT)

