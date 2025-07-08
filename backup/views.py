import json
import os
from django.http import JsonResponse, FileResponse, Http404
import plotly.express as px
import pandas as pd

from calculations.models import ModelRun
from calculations.tasks import execute_r_script
from django.views.decorators.csrf import csrf_exempt




import subprocess
from django.shortcuts import render, redirect
from .models import ModelRun
from .forms import ModelRunForm
from django.conf import settings

def run_model(request):
    if request.method == "POST":
        form = ModelRunForm(request.POST, request.FILES)
        if form.is_valid():
            # Save uploaded file
            input_file = request.FILES["input_file"]
            upload_dir = os.path.join(settings.MEDIA_ROOT, "uploads")
            os.makedirs(upload_dir, exist_ok=True)
            input_file_path = os.path.join(upload_dir, input_file.name)
            with open(input_file_path, "wb+") as destination:
                for chunk in input_file.chunks():
                    destination.write(chunk)

            # Get form values
            model_name = form.cleaned_data["model_name"]
            run_nr = form.cleaned_data["Run_Nr"]
            prev_run_nr = form.cleaned_data["PrevRun_Nr"]
            nb_run_nr = form.cleaned_data["NBRun_Nr"]

            # Map model name to R script path
            model_scripts = {
                "ModelA": os.path.join(settings.BASE_DIR, "calculations", "Rscript", "model_a.R"),
                "ModelB": os.path.join(settings.BASE_DIR, "calculations", "Rscript", "model_b.R"),
            }
            rscript_path = model_scripts.get(str(model_name), None)
            if not rscript_path or not os.path.exists(rscript_path):
                form.add_error("model_name", "Selected model script not found.")
                return render(request, "run_model.html", {"form": form})

            # Save the ModelRun instance with status = RUNNING
            model_run = form.save(commit=False)
            model_run.input_file.name = f"uploads/{input_file.name}"
            model_run.status = "RUNNING"
            model_run.save()

            # Run the R script
            try:
                result = subprocess.run(
                    [
                        "Rscript",
                        rscript_path,
                        str(run_nr),
                        str(prev_run_nr),
                        str(nb_run_nr),
                        input_file_path,
                    ],
                    capture_output=True,
                    text=True,
                )
                if result.returncode == 0:
                    model_run.status = "SUCCESS"
                    success = True
                    output = result.stdout
                else:
                    model_run.status = "FAILED"
                    success = False
                    output = result.stderr
            except Exception as e:
                model_run.status = "FAILED"
                success = False
                output = str(e)

            model_run.save()  # Save updated status

            return render(request, "run_model.html", {
                "form": form,
                "script_success": success,
                "script_output": output,
            })

    else:
        form = ModelRunForm()
    return render(request, "run_model.html", {"form": form})







import subprocess
from django.http import JsonResponse
from django.views.decorators.csrf import csrf_exempt
import os
from django.conf import settings

@csrf_exempt
def run_ifrs9_script(request):
    if request.method == "POST":
        script_path = os.path.join(
            settings.BASE_DIR, "calculations", "Rscript", "IFRS9.3.R"
        )
        try:
            result = subprocess.run(
                ["Rscript", script_path],
                capture_output=True,
                text=True,
                check=True,
            )
            return JsonResponse({"success": True, "output": result.stdout})
        except subprocess.CalledProcessError as e:
            return JsonResponse({"success": False, "error": e.stderr}, status=500)
    return JsonResponse({"error": "POST request required"}, status=405)

def download_report(request, filename):
    file_path = os.path.join(settings.BASE_DIR, "calculations", "Rscript", "output", "IFRS9_outputs", filename)
    if os.path.exists(file_path):
        return FileResponse(open(file_path, "rb"), as_attachment=True)
    else:
        raise Http404("File not found")

from django.shortcuts import render
from .models import ModelRun

def model_run_history(request):
    runs = ModelRun.objects.all().order_by('-created_at')
    return render(request, 'model_run_history.html', {'runs': runs})
