import 'dart:convert';
import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:lion_air_flutter/data/transit.dart';
import 'package:lion_air_flutter/utils/color_utils.dart';
import 'package:lion_air_flutter/view/home/controller/home_controller.dart';
import 'package:lion_air_flutter/view/widget/appbar_widget.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final HomeController _homeController = Get.find();

  final TextEditingController departureController = TextEditingController();
  final TextEditingController arrivalController = TextEditingController();
  final TextEditingController departTimeController = TextEditingController();
  final TextEditingController passengerSeatController = TextEditingController();

  late MqttServerClient client;
  final String mqttBroker = '127.0.0.1';
  final String mqttTopic = 'lion_air_notifications';
  final int mqttPort = 8000;

  RxBool isLogin = false.obs;
  RxBool isOrdered = false.obs;

  RxString selectedArrivalTime = ''.obs;
  RxString selectedTransitTime = ''.obs;
  RxString selectedDepartureTime = ''.obs;
  DateTime selectedDate = DateTime.now();

  RxString currentLocation = ''.obs;
  RxString currentTime = ''.obs;

  RxString departureAirport = ''.obs;
  RxString arrivalAirport = ''.obs;

  void _onConnected() =>
      log('Connected to MQTT broker!', name: 'Lion Air Booking App');

  void _onDisconnected() =>
      log('Disconnected from MQTT broker!', name: 'Lion Air Booking App');

  void _onSubscribeFail(String topic) => Get.snackbar(
        'Lion Air Booking App',
        'Failed to subscribe to $topic!',
        colorText: Colors.white,
        backgroundColor: Colors.redAccent.withOpacity(0.6),
      );

  void _subscribeToTopic(String topic) {
    try {
      client.subscribe(topic, MqttQos.atLeastOnce);
      client.updates!.listen((event) {
        log('${client.connectionStatus!.state}', name: 'debug-connection');

        final MqttPublishMessage received =
            event[0].payload as MqttPublishMessage;
        final String message =
            MqttPublishPayload.bytesToStringAsString(received.payload.message);

        _changeHandler(message);
        // log(message, name: 'message-log');
      });
    } catch (ex) {
      log('Error: $ex', name: 'error-subscribing');
    }
  }

  void _changeHandler(String message) {
    final Map<String, dynamic> changeMap = json.decode(message);

    final String location = changeMap['location'];
    final String time = changeMap['date'];

    final transitChange = TransitChange(location: location, time: time);

    currentLocation.value = transitChange.location;
    currentTime.value = transitChange.time;

    selectedArrivalTime.value = DateFormat('MMMM dd, yyyy hh:mm a').format(
      DateFormat('MMMM dd, yyyy hh:mm a').parse(currentTime.value).add(
            const Duration(
              hours: 1,
            ),
          ),
    );

    log(
      'Received transit changes: $transitChange',
      name: 'debug-changes',
    );
  }

  void _initMqtt() async {
    client = MqttServerClient.withPort(mqttBroker, mqttTopic, mqttPort);

    client.logging(on: false);
    client.onConnected = _onConnected;
    client.onDisconnected = _onDisconnected;
    client.onSubscribeFail = _onSubscribeFail;

    await client.connect();
    _subscribeToTopic(mqttTopic);
  }

  void _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2025),
    );

    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;

        departTimeController.text =
            '${DateFormat('MMMM dd, yyyy').format(selectedDate)} ${selectedDepartureTime.value}';

        DateTime dateTimeTrans = DateFormat('MMMM dd, yyyy hh:mm a')
            .parse(departTimeController.text);
        selectedTransitTime.value = DateFormat('MMMM dd, yyyy hh:mm a')
            .format(dateTimeTrans.add(const Duration(hours: 1)));

        DateTime dateTimeArr = DateFormat('MMMM dd, yyyy hh:mm a')
            .parse(selectedTransitTime.value)
            .add(const Duration(hours: 2));
        selectedArrivalTime.value =
            DateFormat('MMMM dd, yyyy hh:mm a').format(dateTimeArr);

        log('arrival: ${selectedArrivalTime.value}');
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _initMqtt();
  }

  @override
  void reassemble() {
    super.reassemble();
    _initMqtt();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      backgroundColor: kPrimaryColor,
      appBar: CustomAppBar(
        isLogin: isLogin,
        height: 75.h,
        child: Padding(
          padding: EdgeInsets.all(16.h),
          child: Row(
            children: [
              Image(
                image: const AssetImage('assets/img/logo.png'),
                height: 36.h,
              ),
              SizedBox(width: 8.w),
              Row(
                children: [
                  GestureDetector(
                    onTap: () {},
                    child: const Text(
                      'Home',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  GestureDetector(
                    onTap: () {},
                    child: const Text(
                      'Special Offers',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
              const Spacer(),
              GestureDetector(
                onTap: () => isLogin.value = !isLogin.value,
                child: Row(
                  children: [
                    const Icon(
                      Icons.login_outlined,
                      color: kSecondaryColor,
                    ),
                    SizedBox(width: 2.w),
                    Obx(
                      () => isLogin.value
                          ? const Text(
                              'Lion User',
                              style: TextStyle(color: kSecondaryColor),
                            )
                          : const Text(
                              'Login',
                              style: TextStyle(color: kSecondaryColor),
                            ),
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 56.w),
          width: 1.sw,
          child: Column(
            children: [
              SizedBox(height: 64.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'More Than Just A Trip',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10.sp,
                        ),
                      ),
                      const Text(
                        'Lion Air Group is committed to a\n'
                        'continuous improvement of provided\n'
                        'services quality.',
                        overflow: TextOverflow.ellipsis,
                        maxLines: 3,
                        softWrap: true,
                        style: TextStyle(color: Colors.white),
                      ),
                      SizedBox(height: 16.h),
                      Image(
                        image: const AssetImage('assets/img/banner1.png'),
                        height: 132.h,
                        alignment: Alignment.centerLeft,
                      ),
                      SizedBox(height: 2.h),
                      Image(
                        image: const AssetImage('assets/img/banner2.png'),
                        height: 132.h,
                        alignment: Alignment.centerLeft,
                      ),
                      SizedBox(height: 2.h),
                      Image(
                        image: const AssetImage('assets/img/banner3.png'),
                        height: 132.h,
                        alignment: Alignment.centerLeft,
                      ),
                    ],
                  ),
                  buildReservationCard(),
                ],
              ),
              SizedBox(height: 24.h),
              Obx(
                () => isLogin.value && isOrdered.value
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Bon Voyage, Lion Air User!',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12.sp,
                            ),
                          ),
                          SizedBox(height: 16.h),
                          buildTicketStack(),
                        ],
                      )
                    : const SizedBox(),
              ),
              SizedBox(height: 24.h),
            ],
          ),
        ),
      ),
    );
  }

  Stack buildTicketStack() {
    return Stack(children: [
      const Image(
        image: AssetImage('assets/img/ticket1.png'),
      ),
      Positioned(
        left: 30.w,
        top: 55.h,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'FROM',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w500,
                fontSize: 2.5.sp,
              ),
            ),
            Text(
              departureAirport.value,
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 10.5.sp,
              ),
            ),
            Text(
              departTimeController.text,
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w500,
                fontSize: 2.5.sp,
              ),
            ),
          ],
        ),
      ),
      Positioned(
        left: 77.w,
        top: 55.h,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'TRANSIT',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w500,
                fontSize: 2.5.sp,
              ),
            ),
            Obx(
              () =>
                  currentLocation.value == '' || currentLocation.value == 'SOC'
                      ? Text(
                          'SOC',
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 10.5.sp,
                          ),
                        )
                      : Text(
                          currentLocation.value,
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 10.5.sp,
                          ),
                        ),
            ),
            Obx(
              () => currentTime.value == ''
                  ? Text(
                      selectedTransitTime.value,
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w500,
                        fontSize: 2.5.sp,
                      ),
                    )
                  : Text(
                      currentTime.value,
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w500,
                        fontSize: 2.5.sp,
                      ),
                    ),
            ),
          ],
        ),
      ),
      Positioned(
        left: 130.w,
        top: 55.h,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'TO',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w500,
                fontSize: 2.5.sp,
              ),
            ),
            Text(
              arrivalAirport.value,
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 10.5.sp,
              ),
            ),
            Text(
              selectedArrivalTime.value,
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w500,
                fontSize: 2.5.sp,
              ),
            ),
          ],
        ),
      ),
    ]);
  }

  Card buildReservationCard() {
    return Card(
      margin: EdgeInsets.only(top: 24.h),
      elevation: 1.h,
      shadowColor: kDarkColorGrey,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Container(
        width: 115.w,
        height: 450.h,
        color: kPrimaryColor,
        child: Padding(
          padding: EdgeInsets.only(left: 24.h, right: 24.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 24.h),
              const Text(
                'DEPARTURE AIRPORT',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
              Obx(
                () => departureController.text.length > 28
                    ? TextField(
                        readOnly: true,
                        onTap: _showDepartureAirportDialog,
                        controller: departureController,
                        decoration: InputDecoration(
                          hintText: departureAirport.value == ''
                              ? 'Select Airport'
                              : departureController.text,
                          hintStyle: const TextStyle(color: Colors.white70),
                          border: InputBorder.none,
                        ),
                        style: TextStyle(
                          color: kSecondaryColor,
                          fontSize: 5.5.sp,
                        ),
                      )
                    : TextField(
                        readOnly: true,
                        onTap: _showDepartureAirportDialog,
                        controller: departureController,
                        decoration: InputDecoration(
                          hintText: departureAirport.value == ''
                              ? 'Select Airport'
                              : departureController.text,
                          hintStyle: const TextStyle(color: Colors.white70),
                          border: InputBorder.none,
                        ),
                        style: TextStyle(
                          color: kSecondaryColor,
                          fontSize: 7.sp,
                        ),
                      ),
              ),
              SizedBox(height: 24.h),
              const Text(
                'ARRIVAL AIRPORT',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
              Obx(
                () => arrivalController.text.length > 28
                    ? TextField(
                        readOnly: true,
                        onTap: () {
                          if (departureController.text == '') {
                            Get.snackbar(
                              'Lion Air Booking App',
                              'Choose Departure & Arrival Time First!',
                              colorText: Colors.white,
                              backgroundColor:
                                  Colors.redAccent.withOpacity(0.6),
                              borderRadius: 8.r,
                            );
                          } else {
                            _showArrivalAirportDialog(departureAirport.value);
                          }
                        },
                        controller: arrivalController,
                        decoration: InputDecoration(
                          hintText: arrivalAirport.value == ''
                              ? 'Select Airport'
                              : arrivalController.text,
                          hintStyle: const TextStyle(color: Colors.white70),
                          border: InputBorder.none,
                        ),
                        style: TextStyle(
                          color: kSecondaryColor,
                          fontSize: 5.5.sp,
                        ),
                      )
                    : TextField(
                        readOnly: true,
                        onTap: () {
                          if (departureController.text == '') {
                            Get.snackbar(
                              'Lion Air Booking App',
                              'Choose Departure & Arrival Time First!',
                              colorText: Colors.white,
                              backgroundColor:
                                  Colors.redAccent.withOpacity(0.6),
                              borderRadius: 8.r,
                            );
                          } else {
                            _showArrivalAirportDialog(departureAirport.value);
                          }
                        },
                        controller: arrivalController,
                        decoration: InputDecoration(
                          hintText: arrivalAirport.value == ''
                              ? 'Select Airport'
                              : arrivalController.text,
                          hintStyle: const TextStyle(color: Colors.white70),
                          border: InputBorder.none,
                        ),
                        style: TextStyle(
                          color: kSecondaryColor,
                          fontSize: 7.sp,
                        ),
                      ),
              ),
              Container(
                margin: EdgeInsets.only(
                  left: 4.w,
                  right: 4.w,
                  top: 24.h,
                  bottom: 24.h,
                ),
                height: 1.h,
                width: 95.w,
                color: kDarkColorGrey,
              ),
              TextField(
                readOnly: true,
                onTap: () {
                  if (departTimeController.text == '' &&
                      arrivalController.text == '') {
                    Get.snackbar(
                      'Lion Air Booking App',
                      'Choose Departure & Arrival Time First!',
                      colorText: Colors.white,
                      backgroundColor: Colors.redAccent.withOpacity(0.6),
                      borderRadius: 8.r,
                    );
                  } else {
                    _selectDate(context);
                  }
                },
                controller: departTimeController,
                decoration: InputDecoration(
                  hintText: departTimeController.text == ''
                      ? 'Select Departure Date'
                      : departTimeController.text,
                  hintStyle: const TextStyle(color: Colors.white70),
                  border: InputBorder.none,
                  prefixIcon: const Icon(
                    CupertinoIcons.calendar,
                    color: kDarkColorGrey,
                  ),
                  suffixIcon: const Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: Colors.white,
                  ),
                ),
                style: const TextStyle(
                  color: kSecondaryColor,
                ),
              ),
              SizedBox(height: 8.h),
              TextField(
                readOnly: true,
                onTap: () {
                  if (departTimeController.text == '' &&
                      arrivalController.text == '') {
                    Get.snackbar(
                      'Lion Air Booking App',
                      'Choose Departure & Arrival Time First!',
                      colorText: Colors.white,
                      backgroundColor: Colors.redAccent.withOpacity(0.6),
                      borderRadius: 8.r,
                    );
                  } else {
                    showDialog(
                      context: context,
                      builder: (context) => _buildFlightSeat(),
                    );
                  }
                },
                controller: passengerSeatController,
                decoration: InputDecoration(
                  hintText: passengerSeatController.text == ''
                      ? 'Select Your Seat'
                      : passengerSeatController.text,
                  hintStyle: const TextStyle(color: Colors.white70),
                  border: InputBorder.none,
                  prefixIcon: const Icon(
                    Icons.event_seat_rounded,
                    color: kDarkColorGrey,
                  ),
                  suffixIcon: const Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: Colors.white,
                  ),
                ),
                style: const TextStyle(
                  color: kSecondaryColor,
                ),
              ),
              Container(
                margin: EdgeInsets.only(
                  left: 4.w,
                  right: 4.w,
                  top: 24.h,
                  bottom: 24.h,
                ),
                height: 1.h,
                width: 95.w,
                color: kDarkColorGrey,
              ),
              SizedBox(height: 8.h),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    if (departureController.text != '' &&
                        arrivalController.text != '' &&
                        departTimeController.text != '' &&
                        passengerSeatController.text != '' &&
                        isLogin.value == false) {
                      Get.snackbar(
                        'Lion Air Booking App',
                        'Please login & resubmit!',
                        colorText: Colors.white,
                        backgroundColor: Colors.redAccent.withOpacity(0.6),
                        borderRadius: 8.r,
                      );
                    } else if (departureController.text != '' &&
                        arrivalController.text != '' &&
                        departTimeController.text != '' &&
                        passengerSeatController.text != '' &&
                        isLogin.value == true) {
                      isOrdered.value = true;

                      Get.snackbar(
                        'Lion Air Booking App',
                        'Registration Success! Your ticket is ready, bon voyage!',
                        colorText: kPrimaryColor,
                        backgroundColor: kSecondaryColor,
                        borderRadius: 8.r,
                      );
                    } else if (departureController.text != '' &&
                        arrivalController.text != '' &&
                        departTimeController.text != '' &&
                        passengerSeatController.text != '' &&
                        isLogin.value == true) {
                      Get.snackbar(
                        'Lion Air Booking App',
                        'Please fill all the form first!',
                        colorText: Colors.white,
                        backgroundColor: Colors.redAccent.withOpacity(0.6),
                        borderRadius: 8.r,
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                      elevation: 0,
                      fixedSize: Size(95.w, 40.h),
                      backgroundColor: kSecondaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      )),
                  child: const Text(
                    'Order Now',
                    style: TextStyle(
                      color: kPrimaryColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDepartureAirportDialog() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            elevation: 1,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.r),
            ),
            backgroundColor: kPrimaryColor,
            title: const Text(
              'Choose Departure Airport',
              style: TextStyle(color: Colors.white),
            ),
            content: SingleChildScrollView(
              child: Column(
                children: _homeController.departureCodes.toSet().map((e) {
                  String airportName = _homeController.airportCodeMap(e);

                  return ListTile(
                    title: Text(
                      '$airportName ($e)',
                      style: const TextStyle(color: kSecondaryColor),
                    ),
                    onTap: () {
                      departureAirport.value = e;
                      departureController.text = '$airportName ($e)';
                      Get.back();

                      // log(
                      //   'Current Departure: ${departureAirport.value}',
                      //   name: 'debug-change',
                      // );
                    },
                  );
                }).toList(),
              ),
            ),
          );
        });
  }

  void _showArrivalAirportDialog(String departureCode) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          List<Map<String, String>> filteredRoute =
              _homeController.flightRoutes[departureCode] ?? [];
          // log('$filteredRoute $departureCode');

          return AlertDialog(
            elevation: 1,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.r),
            ),
            backgroundColor: kPrimaryColor,
            title: const Text(
              'Choose Arrival Airport',
              style: TextStyle(color: Colors.white),
            ),
            content: SingleChildScrollView(
              child: Column(
                children: filteredRoute.map((e) {
                  String arrivalCode = e['arrival'] ?? '';
                  String departureTime = e['time'] ?? '';

                  String airportName =
                      _homeController.airportCodeMap(arrivalCode);

                  return ListTile(
                    title: Text(
                      '$airportName ($arrivalCode)',
                      style: const TextStyle(color: kSecondaryColor),
                    ),
                    onTap: () {
                      arrivalAirport.value = arrivalCode;
                      arrivalController.text = '$airportName ($arrivalCode)';

                      selectedDepartureTime.value = departureTime;
                      Get.back();

                      // log(
                      //   'Current Departure: ${arrivalAirport.value} ${selectedDepartureTime.value}',
                      //   name: 'debug-change',
                      // );
                    },
                  );
                }).toList(),
              ),
            ),
          );
        });
  }

  Widget _buildFlightSeat() {
    List<List<RxInt>> seatList = [
      [0.obs, 0.obs, 0.obs],
      [0.obs, 0.obs, 0.obs],
      [0.obs, 0.obs, 0.obs],
      [0.obs, 0.obs, 0.obs],
      [0.obs, 0.obs, 0.obs],
      [0.obs, 0.obs, 0.obs],
      [0.obs, 0.obs, 0.obs],
      [0.obs, 0.obs, 0.obs],
      [0.obs, 0.obs, 0.obs],
      [0.obs, 0.obs, 0.obs],
      [0.obs, 0.obs, 0.obs],
      [0.obs, 0.obs, 0.obs],
      [0.obs, 0.obs, 0.obs],
      [0.obs, 0.obs, 0.obs],
      [0.obs, 0.obs, 0.obs],
    ];

    void toggleSeat(int rowId, int colId) {
      seatList[rowId][colId].value = 1 - seatList[rowId][colId].value;
      String row = '';

      switch (rowId) {
        case 0:
          row = 'A';
          break;
        case 1:
          row = 'B';
          break;
        case 2:
          row = 'C';
          break;
        case 3:
          row = 'D';
          break;
        case 4:
          row = 'E';
          break;
        case 5:
          row = 'F';
          break;
        case 6:
          row = 'G';
          break;
        case 7:
          row = 'H';
          break;
        case 8:
          row = 'I';
          break;
        case 9:
          row = 'J';
          break;
        case 10:
          row = 'K';
          break;
        case 11:
          row = 'L';
          break;
        case 12:
          row = 'M';
          break;
        case 13:
          row = 'N';
          break;
        case 14:
          row = 'O';
          break;
        case 15:
          row = 'P';
          break;
      }

      if (seatList[rowId][colId].value == 1) {
        // log('$row$colId', name: 'selected');
        passengerSeatController.text = '$row$colId';
      } else {
        // log('$row$colId', name: 'unselected');
        passengerSeatController.text = '';
      }
    }

    return Dialog(
      backgroundColor: kPrimaryColor,
      child: Column(
        children: [
          SizedBox(height: 16.h),
          Text(
            'Select your seat',
            style: TextStyle(
              fontSize: 12.sp,
              color: kSecondaryColor,
            ),
          ),
          SizedBox(height: 8.h),
          Container(
            width: 100.w,
            height: 1.sh - 200.h,
            margin: EdgeInsets.only(top: 8.h, left: 16.w, right: 16.w),
            child: GridView.builder(
              itemCount: seatList.length * seatList[0].length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: seatList[0].length,
                childAspectRatio: 2.0,
                mainAxisSpacing: 2.0,
                crossAxisSpacing: 1.0,
              ),
              itemBuilder: (context, index) {
                int rowId = index ~/ seatList[0].length;
                int colId = index % seatList[0].length;

                return Material(
                  color: kPrimaryColor,
                  child: InkWell(
                    onTap: () => toggleSeat(rowId, colId),
                    child: Obx(
                      () => seatList[rowId][colId].value == 0
                          ? Container(
                              decoration: BoxDecoration(
                                color: kSecondaryColor,
                                borderRadius: BorderRadius.circular(5.r),
                              ),
                              child: const Center(
                                child: Text(
                                  '',
                                  style: TextStyle(
                                    fontSize: 24.0,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            )
                          : Container(
                              decoration: BoxDecoration(
                                color: kDarkColorGrey,
                                borderRadius: BorderRadius.circular(5.r),
                              ),
                              child: const Center(
                                child: Text(
                                  'X',
                                  style: TextStyle(
                                    fontSize: 24.0,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
