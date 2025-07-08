from django import forms
from .models import ModelRun, ModelScript

# class ModelRunForm(forms.ModelForm):
#     script = forms.ModelChoiceField(
#         queryset=ModelScript.objects.all(),
#         label="Model Script",
#         empty_label="Select a model",
#         widget=forms.Select(attrs={"class": "form-control"})
#     )

#     input_file = forms.FileField(
#         required=True,
#         widget=forms.ClearableFileInput(attrs={"multiple": True, "class": "form-control"}),
#         label="Upload one or two Excel files"
#     )

#     PrevRun_Nr = forms.DateField(
#         widget=forms.DateInput(attrs={"type": "month", "class": "form-control"}),
#         label="Previous Run Date"
#     )

#     NBRun_Nr = forms.DateField(
#         widget=forms.DateInput(attrs={"type": "month", "class": "form-control"}),
#         label="New Business Run Date"
#     )

#     class Meta:
#         model = ModelRun
#         fields = ["script", "PrevRun_Nr", "NBRun_Nr", "input_file"]

# class MultiFileForm(forms.Form):
#     script = forms.ModelChoiceField(
#         queryset=ModelScript.objects.all(),
#         label="Model Script",
#         empty_label="Select a model",
#         widget=forms.Select(attrs={"class": "form-control"})
#     )
#     input_files = forms.FileField(
#         widget=forms.FileInput(attrs={"multiple": True, "class": "form-control"}),
#         label="Upload Excel files"
#     )
#     PrevRun_Nr = forms.DateField(
#         widget=forms.DateInput(attrs={"type": "month", "class": "form-control"}),
#         label="Previous Run Date"
#     )
#     NBRun_Nr = forms.DateField(
#         widget=forms.DateInput(attrs={"type": "month", "class": "form-control"}),
#         label="New Business Run Date"
#     )
