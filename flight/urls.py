from django.urls import path, include
from flight import views

urlpatterns = [
    path("", views.index, name="index"),
]
