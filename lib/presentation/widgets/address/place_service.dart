import 'dart:convert';
import 'dart:io';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart';

class Place {
  String? streetNumber;
  String? street;
  String? city;
  String? zipCode;
  String? areaLvl1;
  String? areaLvl2;
  String? areaLvl3;

  Place({
    this.streetNumber,
    this.street,
    this.city,
    this.zipCode,
    this.areaLvl1,
    this.areaLvl2,
    this.areaLvl3,
  });

  @override
  String toString() {
    return '{"areaLvl1": "$areaLvl1", "areaLvl2": "$areaLvl2", "areaLvl3": "$areaLvl3", "streetNumber": "$streetNumber", "street": "$street", "city": "$city", "zipCode": "$zipCode"}';
  }

  Place.fromJsonString(String jsonString) {
    print("fromJsonString object $jsonString");
    Map<String, dynamic> json = jsonDecode(jsonString);
    areaLvl1 = json['areaLvl1'];
    areaLvl2 = json['areaLvl2'];
    areaLvl3 = json['areaLvl3'];
    streetNumber = json['streetNumber'];
    street = json['street'];
    city = json['city'];
    zipCode = json['zipCode'];
  }
}

class Suggestion {
  final String placeId;
  final String description;

  Suggestion(this.placeId, this.description);

  @override
  String toString() {
    return 'Suggestion(description: $description, placeId: $placeId)';
  }
}

class PlaceApiProvider {
  final client = Client();

  PlaceApiProvider(this.sessionToken);

  final sessionToken;

  final String searchCountry = 'pt';
  static final String androidKey = dotenv.env["MAPS_ANDROID_API_KEY"]!;
  static final String iosKey = dotenv.env["MAPS_IOS_API_KEY"]!;
  final apiKey = Platform.isAndroid ? androidKey : iosKey;

  Future<List<Suggestion>> fetchSuggestions(String input, String lang) async {
    final request =
        'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$input&types=administrative_area_level_3&language=$lang&components=country:$searchCountry&key=$apiKey&sessiontoken=$sessionToken';
    final response = await client.get(Uri.parse(request));

    if (response.statusCode == 200) {
      final result = json.decode(response.body);
      if (result['status'] == 'OK') {
        // compose suggestions in a list
        return result['predictions']
            .map<Suggestion>((p) => Suggestion(p['place_id'], p['description']))
            .toList();
      }
      if (result['status'] == 'ZERO_RESULTS') {
        return [];
      }
      throw Exception(result['error_message']);
    } else {
      throw Exception('Failed to fetch suggestion');
    }
  }

  Future<Place> getPlaceDetailFromId(String placeId) async {
    final request =
        'https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&fields=address_component&key=$apiKey&sessiontoken=$sessionToken';
    final response = await client.get(Uri.parse(request));

    if (response.statusCode == 200) {
      final result = json.decode(response.body);
      if (result['status'] == 'OK') {
        final components =
            result['result']['address_components'] as List<dynamic>;
        // build result
        final place = Place();
        for (var c in components) {
          final type = c['types'];
          if (type.contains('administrative_area_level_1')) {
            place.areaLvl1 = c['long_name'];
          }
          if (type.contains('administrative_area_level_2')) {
            place.areaLvl2 = c['long_name'];
          }
          if (type.contains('administrative_area_level_3')) {
            place.areaLvl3 = c['long_name'];
          }
          if (type.contains('street_number')) {
            place.streetNumber = c['long_name'];
          }
          if (type.contains('route')) {
            place.street = c['long_name'];
          }
          if (type.contains('locality')) {
            place.city = c['long_name'];
          }
          if (type.contains('postal_code')) {
            place.zipCode = c['long_name'];
          }
        }
        return place;
      } else if (result['status'] == 'INVALID_REQUEST') {
        return Place();
      }
      throw Exception(result['error_message']);
    } else {
      throw Exception('Failed to fetch suggestion');
    }
  }
}
