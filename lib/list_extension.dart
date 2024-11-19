import 'package:nendoroid_scraper/nendo_korean_model.dart';

extension ListExtension on List<NendoKoreanModel> {
  // number로 이름 찾기
  String findNameByNumber(String number) {
    final nendoKoreanModel = this.firstWhere((element) => element.num == number, orElse: () => NendoKoreanModel(name: '', num: '', series: ''));
    return nendoKoreanModel.name;
  }

  // number로 시리즈 찾기
  String findSeriesByNumber(String number) {
    final nendoKoreanModel = this.firstWhere((element) => element.num == number, orElse: () => NendoKoreanModel(name: '', num: '', series: ''));
    return nendoKoreanModel.series;
  }
}