from django.shortcuts import render
from django.http import JsonResponse

# Create your views here.
def index(request):
    return render(request, "index.html", context={})

def health_check(request):
    return JsonResponse({"status": "ok"})