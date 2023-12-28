import 'package:get/get.dart';

class HomeController extends GetxController {
  List<String> departureCodes = [
    'CGK',
    'PGK',
    'CGK',
    'PGK',
    'CGK',
    'PGK',
    'PLM',
    'BDO',
    'BDO',
    'PKU',
    'PDG',
    'CGK',
    'PKU',
    'DJB',
    'DJJ',
    'DJJ',
    'CGK',
    'CGK',
    'SUB',
    'CGK',
    'CGK',
  ];

  List<String> arrivalCodes = [
    'PGK',
    'CGK',
    'PGK',
    'CGK',
    'PGK',
    'CGK',
    'BDO',
    'PLM',
    'BDJ',
    'BTH',
    'BTH',
    'PKU',
    'CGK',
    'CGK',
    'MKQ',
    'CGK',
    'MLG',
    'DTB',
    'LBJ',
    'BWX',
    'DJB',
  ];

  Map<String, List<Map<String, String>>> flightRoutes = {
    'CGK': [
      {'arrival': 'PGK', 'time': '12:10 PM'},
      {'arrival': 'PKU', 'time': '06:45 AM'},
      {'arrival': 'MLG', 'time': '02:30 AM'},
      {'arrival': 'DTB', 'time': '07:20 AM'},
      {'arrival': 'BWX', 'time': '08:25 AM'},
      {'arrival': 'DJB', 'time': '03:00 PM'},
    ],
    'PGK': [
      {'arrival': 'CGK', 'time': '02:10 PM'},
    ],
    'PLM': [
      {'arrival': 'BDO', 'time': '07:00 AM'},
    ],
    'BDO': [
      {'arrival': 'PLM', 'time': '07:00 PM'},
      {'arrival': 'BDJ', 'time': '09:00 AM'},
    ],
    'PKU': [
      {'arrival': 'BTH', 'time': '04:40 PM'},
      {'arrival': 'CGK', 'time': '09:00 AM'},
    ],
    'PDG': [
      {'arrival': 'BTH', 'time': '05:25 PM'},
    ],
    'DJB': [
      {'arrival': 'CGK', 'time': '03:35 PM'},
    ],
    'DJJ': [
      {'arrival': 'MKQ', 'time': '01:00 PM'},
      {'arrival': 'CGK', 'time': '03:00 PM'},
    ],
    'SUB': [
      {'arrival': 'LBJ', 'time': '12:45 PM'},
    ],
  };

  String airportCodeMap(String airportCode) {
    Map<String, String> airportMap = {
      'BDO': 'Husein Sastranegara',
      'BDJ': 'Syamsudin Noor',
      'BWX': 'Banyuwangi',
      'BTH': 'Hang Nadim',
      'CGK': 'Soekarno Hatta',
      'DJB': 'Sultan Thaha',
      'DJJ': 'Sentani',
      'DTB': 'Sisingamangaraja XII',
      'LBJ': 'Komodo',
      'MLG': 'Abdul Rachman Saleh',
      'MKQ': 'Mopah',
      'PDG': 'Minangkabau',
      'PGK': 'Pangkalanbuun',
      'PKU': 'Sultan Syarif Kasim II',
      'PLM': 'Sultan Mahmud Badaruddin II',
      'SUB': 'Juanda'
    };

    return airportMap[airportCode] ?? 'Unlisted';
  }
}
