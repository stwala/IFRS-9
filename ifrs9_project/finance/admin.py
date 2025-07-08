from django.contrib import admin
from django.utils.html import format_html
from .models import FinancialInstrument

class FinancialInstrumentAdmin(admin.ModelAdmin):
    list_display = ("name", "classification", "credit_rating", "exposure", "ecl_stage", "ecl_amount", "view_details")
    list_filter = ("classification", "ecl_stage", "credit_rating")
    search_fields = ("name", "credit_rating")
    ordering = ("-exposure",)

    def ecl_amount(self, obj):
        """Display calculated ECL in the admin panel."""
        return f"{obj.calculate_ecl():,.2f}"
    ecl_amount.short_description = "ECL Amount (BWP)"

    def view_details(self, obj):
        """Link to a detailed admin view."""
        return format_html(f'<a href="/admin/finance/financialinstrument/{obj.id}/change/">View</a>')
    view_details.short_description = "Details"

admin.site.register(FinancialInstrument, FinancialInstrumentAdmin)
