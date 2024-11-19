import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as html_parser;
import 'package:nendoroid_scraper/list_extension.dart';
import 'package:nendoroid_scraper/nendo_korean_model.dart';

import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class DownloadManager {
  final String goodSmileKoreaUrl = 'https://brand.naver.com/goodsmilekr/category/fc068adc735c4a4093dd9318b50c053b?st=RECENT&dt=IMAGE&page=1&size=80';
  final String goodSmileKoreaThumbnailListClass = 'ZdiAiTrQWZ _1BDRwBQfa1 SQUARE t52c8ixKbX';
  final String goodSmileKoreaNendoroidNameClass = '_3pA0Duwrhw';

  final String goodSmileJapanUrl = 'https://www.goodsmile.com/ja/product/';
  final String goodSmileEnUrl = 'https://www.goodsmile.com/en/product/';

  final String globalNendoNameClass = 'c-title c-title--level3 b-product-info__title';
  final String globalNendoPriceClass = 'c-price__main';
  final String globalNendoShippingClass = 'c-text-body c-text-body--secondary b-product-info__note';
  final String globalNendoGroupClass = 'b-text-group__unit';
  final String globalNendoSpecificationId = 'specification';
  final String globalNendoGroupContentClass = 'c-text-body';
  final String globalNendoGroupNumberClass = 'b-product-item__image__caption';

  final String nendoroidKo = '넨도로이드';
  final String nendoroidEn = 'Nendoroid';
  final String nendoroidJa = 'ねんどろいど';

  final Map<String, String> _header = {
    'User-Agent': 'Mozilla/5.0 (Windows NT 6.3; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/63.0.3239.132 Safari/537.36',
    'Cookie': 'wcs_bt=s_17766344d46d1:1726706449; Path=/; Expires=Fri, 19 Sep 2025 00:43:33 GMT;',
  };

  List<NendoKoreanModel> _nendoKoreanList = [];

  /// 굿스마의 새로운 페이지는 SPA 방식이라 플러터에서 처음부터 스크래핑을 하기 힘들다.
  /// 따라서 1차로 다른 프로그램을 통해서 각 넘버에 맞는 제품번호를 가져오고, 그 번호를 통해 상세페이지에 접근하여 크롤링을 한다.
  Future<String> fetchNendoEnJaData({required int productNumber}) async {
    final enResponse = await http.get(Uri.parse('$goodSmileEnUrl$productNumber'));
    final jaResponse = await http.get(Uri.parse('$goodSmileJapanUrl$productNumber'));

    if (enResponse.statusCode == 200) {
      try {
        final document = html_parser.parse(enResponse.body);
        final jaDocument = html_parser.parse(jaResponse.body);

        final rawName = document.getElementsByClassName(globalNendoNameClass).firstOrNull!.text;
        final rawJaName = jaDocument.getElementsByClassName(globalNendoNameClass).firstOrNull!.text;

        final rawPrice = document.getElementsByClassName(globalNendoPriceClass).firstOrNull!.text;
        final rawShipping = document.getElementsByClassName(globalNendoShippingClass).firstOrNull?.text ?? '';

        final textGroup = document.getElementById(globalNendoSpecificationId)!;
        final textJaGroup = jaDocument.getElementById(globalNendoSpecificationId)!;

        final number = document.getElementsByClassName(globalNendoGroupNumberClass).firstOrNull!.text.trim();

        final String enName = rawName.replaceAll(nendoroidEn, '').trim();
        final String jaName = rawJaName.replaceAll(nendoroidJa, '').trim();
        final String price = parseNumber(rawPrice);
        final String shipping = parseReleaseDate(rawShipping);
        final String enSeries =
            textGroup.getElementsByClassName(globalNendoGroupClass).first!.getElementsByClassName(globalNendoGroupContentClass).first!.text;
        final String jaSeries =
            textJaGroup.getElementsByClassName(globalNendoGroupClass).first!.getElementsByClassName(globalNendoGroupContentClass).first!.text;

        print('enName: $enName, jaName: $jaName, number: $number, price: $price, shipping: $shipping, enSeries: $enSeries, jaSeries: $jaSeries');
        return '''"name" : {
    "en" : "$enName",
    "ja" : "$jaName",
    "ko" : "${_nendoKoreanList.findNameByNumber(number)}"
  },
  "num" : "$number",
  "price" : $price,
  "release_date" : [
    "$shipping"
  ],
  "series" : {
    "en" : "$enSeries",
    "ja" : "$jaSeries",
    "ko" : "${_nendoKoreanList.findSeriesByNumber(number)}"
  }
        ''';
      } catch (error, stackTrace) {
        print('parse error: $error, $stackTrace');
      }
    } else {
      print('Status code: ${enResponse.statusCode}');
    }
    return '';
  }

  Future<List<NendoKoreanModel>> fetchNendoKoreanData({
    required String startNumber,
  }) async {
    List<NendoKoreanModel> nendoDataList = [];

    final response = await http.get(Uri.parse(goodSmileKoreaUrl), headers: _header);

    if (response.statusCode == 200) {
      final decodedBody = utf8.decode(response.bodyBytes);
      final document = html_parser.parse(decodedBody);
      final thumbnailList = document.getElementsByClassName(goodSmileKoreaThumbnailListClass);

      try {
        for (int i = 0; i < thumbnailList.length; i++) {
          final thumbnail = thumbnailList[i];
          final nendoroidName = thumbnail.getElementsByClassName(goodSmileKoreaNendoroidNameClass).first.text;
          final parseData = parseNendoData(rawNendoData: nendoroidName);

          final String num = parseData.num;
          final String name = parseData.name;
          final String series = parseData.series;

          final nendoData = NendoKoreanModel(name: name, num: num, series: series);
          nendoDataList.add(nendoData);
          print(nendoData.toString());

          if (num == startNumber) {
            break;
          }
        }
      } catch (error, stackTrace) {
        print('parse error: $error, $stackTrace');
      }
    } else {
      print('Status code: ${response.statusCode}');
    }

    _nendoKoreanList = nendoDataList;

    return nendoDataList;
  }

  ({String name, String num, String series}) parseNendoData({
    required String rawNendoData,
  }) {
    // rawNendoData: '[특전] 넨도로이드 2564 이스미 하루카 / 아이돌리쉬 세븐'

    // '넨도로이드' 라는 문자열을 찾고, 그 문자열이 끝나는 인덱스 번호를 찾기
    final nendoIndex = rawNendoData.indexOf(nendoroidKo);
    // '넨도로이드' 라는 문자열과 그 앞의 문자들을 제거
    final nendoData = rawNendoData.substring(nendoIndex + nendoroidKo.length).trim();
    // '/' 문자열 기준으로 스플릿 후 공백제거
    final dataList = nendoData.split('/').map((e) => e.trim()).toList();
    // dataList[0]을 첫번째 공백을 기준으로 스플릿하여 num와 name 추출
    final num = dataList[0].split(' ')[0];
    final name = dataList[0].split(' ').sublist(1).join(' ');
    final series = dataList[1];

    return (
      name: name,
      num: num,
      series: series,
    );
  }

  // 문자열에서 숫자만 찾아서 반환해주는 메소드
  String parseNumber(String rawNumber) {
    final number = rawNumber.replaceAll(RegExp(r'[^0-9]'), '');
    return number;
  }

  String parseReleaseDate(String rawReleaseDate) {
    final trimString = rawReleaseDate.split('・')[0];
    if (trimString.split(' ').length < 2) {
      return rawReleaseDate;
    }
    final rawDate = trimString.split(' ')[1].trim();
    // '/'을 기준으로 문자열 스왑
    return rawDate.split('/').reversed.join('/');
  }
}
