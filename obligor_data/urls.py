from django.urls import include, path

from analyis import views
from .views import *
from .views import (
    neural_networks_view,
    factor_models_view,
    stage1_view,
    stage2_view,
    stage3_view
)
from .views import landing_page


urlpatterns = [
    path("obligor_list/", obligor_list, name="obligor_list"),
    path('home', home, name='home'),
    path("ecl/", include("ecl_calculations.urls")),
    path('neural_networks/', neural_networks_view, name='neural_networks'),
    path('factor_models/', factor_models_view, name='factor_models'),
    path('stage1/', stage1_view, name='stage1'),
    path('stage2/', stage2_view, name='stage2'),
    path('stage3/', stage3_view, name='stage3'),
    path('', landing_page, name='landing_home'),
    
]
