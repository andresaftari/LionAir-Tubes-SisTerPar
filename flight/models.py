# Create your models here.
from datetime import datetime

from django.contrib.auth.models import AbstractUser
from django.db import models


# User
class User(AbstractUser):
    def __str__(self):
        return f'{self.pk}: {self.first_name} {self.last_name}'


# Place
class Place(models.Model):
    city = models.CharField(max_length=64)
    airport = models.CharField(max_length=120)
    code = models.CharField(max_length=3)
    country = models.CharField(max_length=64)
    isTransit = models.BooleanField()

    def __str__(self):
        state = ' - As Transit' if self.isTransit else ''
        return f'{self.city}, {self.country} ({self.code}) {state}'


# Week Format
class Week(models.Model):
    number = models.IntegerField()
    name = models.CharField(max_length=16)

    def __str__(self):
        return f"{self.name} ({self.number})"


# Flight
class Flight(models.Model):
    departure = models.ForeignKey(Place, on_delete=models.CASCADE, related_name='departures')
    destination = models.ForeignKey(Place, on_delete=models.CASCADE, related_name='arrivals')
    transit = models.ForeignKey(Place, on_delete=models.CASCADE, related_name='transits', null=True)

    transite_arrival_time = models.TimeField(auto_now=False, auto_now_add=False, null=True)
    transite_departure_time = models.TimeField(auto_now=False, auto_now_add=False, null=True)
    arrival_time = models.TimeField(auto_now=False, auto_now_add=False)
    departure_time = models.TimeField(auto_now=False, auto_now_add=False)
    departure_day = models.ManyToManyField(Week, related_name='day_of_the_flights')
    duration = models.DurationField(null=False)

    flight_number = models.CharField(max_length=8)
    flight_airline = models.CharField(max_length=32)

    economy_fare = models.FloatField(null=False)
    business_fare = models.FloatField(null=False)

    def __str__(self):
        transit_place = '' if self.transit.null else f'Transit at {self.transit}'
        return f'{self.pk}: {self.flight_number} | {self.departure} to {self.destination} | {transit_place}'


# Passenger
GENDER = (('male', 'MALE'), ('female', 'FEMALE'))


class Passenger(models.Model):
    first_name = models.CharField(max_length=64, blank=True)
    last_name = models.CharField(max_length=64, blank=True)
    gender = models.CharField(max_length=6, choices=GENDER, blank=True)

    def __str__(self):
        if self.gender == 'male':
            return f'Mr. {self.first_name} {self.last_name}'
        elif self.gender == 'female':
            return f'Mrs. {self.first_name} {self.last_name}'
        else:
            return f'{self.first_name} {self.last_name}'


# Ticket
SEAT_CLASS = (
    ('economy', 'Economy'),
    ('business', 'Business')
)

TICKET_STATUS = (
    ('pending', 'Pending'),
    ('confirmed', 'Confirmed'),
    ('cancelled', 'Cancelled')
)


class Ticket(models.Model):
    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name='bookings', null=True, blank=True)
    ref_no = models.CharField(max_length=6, unique=True)
    passengers = models.ManyToManyField(Passenger, related_name='flight_tickets')

    flight = models.ForeignKey(Flight, on_delete=models.CASCADE, related_name='tickets', null=True, blank=True)
    flight_dest_date = models.DateField(blank=True, null=True)
    flight_arr_date = models.DateField(blank=True, null=True)
    flight_fare = models.FloatField(blank=True, null=True)

    total_fare = models.FloatField(blank=True, null=True)

    seat_class = models.CharField(max_length=10, choices=SEAT_CLASS)
    booking_date = models.DateTimeField(default=datetime.now)

    phone = models.CharField(max_length=20, blank=True)
    email = models.EmailField(blank=True)
    status = models.CharField(max_length=20, choices=TICKET_STATUS, blank=True)

    def __str__(self):
        return self.ref_no
