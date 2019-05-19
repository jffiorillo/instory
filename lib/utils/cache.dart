import 'dart:convert';
import 'package:flutter/services.dart';
import '../models.dart';

class Cache {
  static Future<ApiResponse> getCacheProfile() async {
    String contents = await rootBundle.loadString("assets/9gag_stories.json");
    return ApiResponse.fromJson(json.decode(contents));
  }

  static Future<HighLightsResponse> getCacheHighLights() async {
    String contents =
        await rootBundle.loadString("assets/9gag_highlights.json");
    return HighLightsResponse.fromJson(json.decode(contents));
  }

  static Future<SingleHighLightResponse> getCacheHighLight() async {
    String contents =
        await rootBundle.loadString("assets/9gag_single_highlight.json");
    return SingleHighLightResponse.fromJson(
        json.decode(contents), "highlight:17946509755169593");
  }
}
