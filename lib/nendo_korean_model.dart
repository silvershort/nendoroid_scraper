class NendoKoreanModel {
  final String name;
  final String num;
  final String series;

  NendoKoreanModel({
    required this.name,
    required this.num,
    required this.series,
  });

  @override
  String toString() {
    return 'NendoKoreanModel(name: $name, num: $num, series: $series)';
  }
}