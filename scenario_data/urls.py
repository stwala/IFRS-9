from django.urls import path
from . import views
from django.conf import settings
from django.conf.urls.static import static


urlpatterns = [
    path('scenario/', views.scenario_data, name='scenario_data'),
    path('gdp/', views.gdp_list, name='gdp_list'),
    path('unemployment/', views.unemployment_list, name='unemployment_list'),
    path('inflation/', views.inflation_list, name='inflation_list'),
    path('logistic-regression/', views.logistic_regression_view, name='logistic_regression_detail'),
]
if settings.DEBUG:
    urlpatterns += static(settings.MEDIA_URL, document_root=settings.MEDIA_ROOT)