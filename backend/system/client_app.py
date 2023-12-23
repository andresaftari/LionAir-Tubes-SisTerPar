from datetime import datetime
import paho.mqtt.client as mqtt

'''
Departure:
- Departure Location: SOEKARNO HATTA INTERNATIONAL AIRPORT (CGK), Jakarta, Indonesia
- Departure Date: December 1, 2023
- Departure Time: 16:30 (West Indonesian Time)

Transit:
- Transit Location: Heathrow Airport (LHR), London, United Kingdom
- Transit Date: December 2, 2023
- Transit Time: 08:45 (West Indonesian Time)
'''

# coba coba format waktu
print(datetime.now().strftime('%B %d, %Y %H:%M:%S'), end='')

# MQTT settings
MQTT_BROKER = "mqtt.eclipse.org"
TOPIC_BOARDING = "tubes_lion_air_boarding"
TOPIC_TRANSIT = "tubes_lion_air_transit"



