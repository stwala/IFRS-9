import os
import subprocess
from django.shortcuts import render
from django.conf import settings
from .models import ModelScript, ModelRun

def run_model_view(request):
    error = None
    message = None

    if request.method == "POST":
        try:
            script_id = request.POST.get("script")
            prev_run = request.POST.get("PrevRun_Nr")
            nb_run = request.POST.get("NBRun_Nr")
            file1 = request.FILES.get("input_file1")
            file2 = request.FILES.get("input_file2")
            file3 = request.FILES.get("input_file3")

            if not all([script_id, prev_run, nb_run, file1, file2, file3]):
                message = "All fields including the 3 input files must be provided."
                return render(request, "run_model.html", {
                    "scripts": ModelScript.objects.all(),
                    "error": None,
                    "message": message,
                })

            script = ModelScript.objects.get(id=script_id)

            # Save files to disk
            input_paths = []
            saved_files = []
            for f in [file1, file2, file3]:
                save_path = os.path.join(settings.MEDIA_ROOT, "inputs", f.name)
                os.makedirs(os.path.dirname(save_path), exist_ok=True)
                with open(save_path, "wb+") as destination:
                    for chunk in f.chunks():
                        destination.write(chunk)
                input_paths.append(save_path)
                saved_files.append(f"inputs/{f.name}")

            # Ensure output directory exists
            output_dir = os.path.join(settings.MEDIA_ROOT, "outputs")
            os.makedirs(output_dir, exist_ok=True)

            # Create ModelRun entry (status PENDING)
            model_run = ModelRun.objects.create(
                script=script,
                input_file=saved_files[0],
                PrevRun_Nr=prev_run,
                NBRun_Nr=nb_run,
                status='RUNNING'
            )

            # Run R script
            script_path = os.path.join(settings.MEDIA_ROOT, "scripts", os.path.basename(script.script_file.name))
            cmd = ["Rscript", script_path] + input_paths

            result = subprocess.run(cmd, capture_output=True, text=True)

            if result.returncode != 0:
                model_run.status = 'FAILED'
                model_run.save()
                # Log the error for admin/debugging
                print("Script error:", result.stderr)
                message = "Script failed. Please check your inputs and try again."
            else:
                model_run.status = 'SUCCESS'
                model_run.save()
                message = "Script ran successfully!"

            return render(request, "model_results.html", {
                "message": message,
                "outputs": get_output_files_list(),
            })

        except Exception as e:
            # Log the error for admin/debugging
            print("Exception:", str(e))
            message = "An unexpected error occurred. Please try again."

    return render(request, "run_model.html", {
        "scripts": ModelScript.objects.all(),
        "error": None,
        "message": message,
    })


# Helper function: just returns the list of files
def get_output_files_list():
    output_dir = os.path.join(settings.MEDIA_ROOT, "outputs")
    files = []
    if os.path.exists(output_dir):
        for f in os.listdir(output_dir):
            files.append({
                "name": f,
                "url": f"/media/outputs/{f}"
            })
    return files

# View function: renders the template
def get_output_files(request):
    files = get_output_files_list()
    return render(request, "model_results.html", {
        "outputs": files,
        "message": None,
    })
