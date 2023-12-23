from xmlrpc.server import SimpleXMLRPCServer, SimpleXMLRPCRequestHandler
import paho.mqtt.client as mqtt

'''
1. STREAMLIT / DASHBOARD
2. E-TICKET
3. SISTEM GAUSAH BERUBAH
'''

# Default boarding schedule & transit location
current_boarding_schedule = 'November 30, 2023 15:30'
current_transit = 'Heathrow Airport (LHR)'

# RPC server settings
HOST = "127.0.0.1"
PORT = 5005

# MQTT settings
MQTT_BROKER = "mqtt.eclipse.org"
TOPIC_BOARDING = "tubes_lion_air_boarding"
TOPIC_TRANSIT = "tubes_lion_air_transit"


# RPC class (Server-side)
class RPCHandler:
    def get_boarding_schedule(self):
        return current_boarding_schedule

    def get_transit_location(self):
        return current_transit

    # Notify the changes for boarding
    def notify_boarding_changes(self, new_schedule):
        global current_boarding_schedule
        if new_schedule != current_boarding_schedule:
            current_boarding_schedule = new_schedule
            self.publish_to_mqtt(TOPIC_BOARDING, f"Updated Boarding Schedule: {new_schedule}")

    # Notify the changes for location
    def notify_transit_location(self, new_location):
        global current_transit
        if new_location != current_transit:
            if new_location != '':
                current_transit = new_location
                self.publish_to_mqtt(TOPIC_TRANSIT, f"Updated Transit Location: {new_location}")
            else:
                new_location = 'No Transit'
                self.publish_to_mqtt(TOPIC_TRANSIT, f"Updated Transit Location: {new_location}")

    # Publish message / changes to MQTT
    def publish_to_mqtt(self, topic, message):
        client = mqtt.Client()
        client.connect(MQTT_BROKER)
        client.publish(topic, message)
        client.disconnect()


server = SimpleXMLRPCServer((HOST, PORT), requestHandler=SimpleXMLRPCRequestHandler)
server.register_instance(RPCHandler())

# Debug server HOST & PORT
print(f"======== Listening on {HOST}:{PORT} ========")

try:
    while True:
        schedule_update = ''
        transit_update = ''

        while schedule_update == '':
            print('======== New Flight Schedule is Required! ========')
            print('Department Time Format [ex. December 20, 2023 00.00]')
            schedule_update = input('Please input new flight department time (required): ')

            if schedule_update == current_boarding_schedule:
                break

        if schedule_update != '':
            print('Department Transit Format [ex. Soekarno Hatta (CGK)]')
            transit_update = input('Please input new transit location (optional): ')

        # Server changes notifier
        server.handle_request()  # Server will wait if there is client request
        RPCHandler().notify_boarding_changes(schedule_update)
        RPCHandler().notify_transit_location(transit_update)
except KeyboardInterrupt:
    print('======== Server shutting down ========')
