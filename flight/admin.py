# Register your models here.
from django.contrib import admin
from .models import *

admin.site.register(Place)
admin.site.register(Week)
admin.site.register(Flight)
admin.site.register(Passenger)
admin.site.register(User)
admin.site.register(Ticket)
