from django.urls import re_path, include
from flight import views

urlpatterns = [
    re_path(r'index/', views.index)
]
