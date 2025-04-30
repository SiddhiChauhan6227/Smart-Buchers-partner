import 'package:erestro/Helper/session.dart';
import 'package:erestro/Helper/string.dart';

class ApiUtils {
  static Future<Map<String, String>> getHeaders() async {
    String? jwtToken = await getPrefrence(token);
    print(jwtToken);
    return {"Authorization": 'Bearer $jwtToken'};
  }
}
