import 'package:test/test.dart';
import 'package:dio/dio.dart';
import 'package:talker/talker.dart';

import 'package:flutter_civitai_box/civitai_api/civitai_api.dart';

void main() {
  final dio = Dio();
  var talker = Talker();
  var civitAIApi = CivitaiApiClient();
  test('Dio request CivitAI model-id endpoint', () async {
    var response = await dio.get('https://civitai.com/api/v1/models/2657416');
    talker.info('Response data: ${response.data}');
  });

  test('request by using CivitAI API client', () async {
    var response = await civitAIApi.models.getById(2657416);
    talker.info(response);
  });
}
