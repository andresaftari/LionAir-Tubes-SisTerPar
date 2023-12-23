from django.shortcuts import render
from django.http import HttpResponse


# Create your views here.
def index(request):
    return render(request, 'flight/templates/flight/index.html', {})


def flight():
    return None