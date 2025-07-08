# from django.contrib import admin
# from import_export.admin import ImportExportModelAdmin
# from import_export import resources
# from .models import Obligor


# class ObligorResource(resources.ModelResource):
#     class Meta:
#         model = Obligor


# class ObligorAdmin(ImportExportModelAdmin, admin.ModelAdmin):
#     resource_class = ObligorResource
#     list_display = ("person_age", "person_income", "loan_intent", "loan_grade", "loan_amnt", "loan_status")
#     list_filter = ("loan_grade", "loan_status", "person_home_ownership")
#     search_fields = ("loan_intent", "person_income")

# admin.site.register(Obligor, ObligorAdmin)


# from django.contrib import admin
# from import_export.admin import ImportExportModelAdmin
# from import_export import resources
# from .models import Obligor

# class ObligorResource(resources.ModelResource):
#     class Meta:
#         model = Obligor

# class ObligorAdmin(ImportExportModelAdmin): 
#     resource_class = ObligorResource
#     list_display = ("person_age", "person_income", "loan_intent", "loan_grade", "loan_amnt", "loan_status")
#     list_filter = ("loan_grade", "loan_status", "person_home_ownership")
#     search_fields = ("loan_intent", "person_income")

# admin.site.register(Obligor, ObligorAdmin)


from django.contrib import admin
from import_export.admin import ImportExportModelAdmin
from import_export import resources
from .models import Obligor

class ObligorResource(resources.ModelResource):
    class Meta:
        model = Obligor

class ObligorAdmin(ImportExportModelAdmin):
    resource_class = ObligorResource
    list_display = ("person_age", "person_income", "loan_intent", "loan_grade", "loan_amnt", "loan_status")
    list_filter = ("loan_grade", "loan_status", "person_home_ownership")
    search_fields = ("loan_intent", "person_income")

    # 🔥 Fix: Manually define 'search_help_text' for Django 3.2 compatibility
    search_help_text = "Search for loan intent or person income"

admin.site.register(Obligor, ObligorAdmin)