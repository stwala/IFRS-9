from django import forms
from .models import ModelRun, ModelScript

class ModelRunForm(forms.ModelForm):
    script = forms.ModelChoiceField(
        queryset=ModelScript.objects.none(),  # default to none
        label="Model Script",
        empty_label="Select a model",
        widget=forms.Select(attrs={"class": "form-control"})
    )

    input_file = forms.FileField(
        required=True,
        label="Input Excel File",
        widget=forms.ClearableFileInput(attrs={"class": "form-control"})
    )

    PrevRun_Nr = forms.DateField(
        widget=forms.DateInput(attrs={"type": "month", "class": "form-control"}),
        label="Previous Run Date"
    )

    NBRun_Nr = forms.DateField(
        widget=forms.DateInput(attrs={"type": "month", "class": "form-control"}),
        label="New Business Run Date"
    )

    class Meta:
        model = ModelRun
        fields = ["script", "PrevRun_Nr", "NBRun_Nr", "input_file"]

    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
        self.fields['script'].queryset = ModelScript.objects.all()
