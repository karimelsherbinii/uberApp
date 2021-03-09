import 'dart:convert';

import 'package:http/http.dart' as http; // important

class RequestHelper {
  static Future<dynamic> getRequest(String url) async {
    http.Response response =
        await http.get(Uri.parse(url)); // this for get url for my app to use it
    try {
      if (response.statusCode == 200) {
        String data = response
            .body; // make the body in a var to use it in tha bottom to convert it to json code
        var decodedData = jsonDecode(data); // for convert to json
        return decodedData;
      } else {
        return 'failed';
      }
    } catch (e) {
      return 'failed';
    }
  }
}
