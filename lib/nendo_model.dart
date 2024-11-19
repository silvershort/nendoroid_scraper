class NendoModel {
  final String gender;
  final int gscProductNum;
  final String image;
  final String num;
  final int price;
  final List<String> releaseDate;
  final Name name;
  final Series series;

  const NendoModel({
    required this.gender,
    required this.gscProductNum,
    required this.image,
    required this.num,
    required this.price,
    required this.releaseDate,
    required this.name,
    required this.series,
  });

  factory NendoModel.fromJson(Map<String, dynamic> json) {
    return NendoModel(
      gender: json['gender'],
      gscProductNum: json['gsc_productNum'],
      image: json['image'],
      num: json['num'],
      price: json['price'],
      releaseDate: List<String>.from(json['release_date']),
      name: Name.fromJson(json['name']),
      series: Series.fromJson(json['series']),
    );
  }


  Map<String, dynamic> toJson() {
    return {
      'gender': gender,
      'gsc_productNum': gscProductNum,
      'image': image,
      'num': num,
      'price': price,
      'release_date': releaseDate,
      'name': name.toJson(),
      'series': series.toJson(),
    };
  }
}

class Name {
  final String en;
  final String ja;
  final String ko;

  const Name({
    required this.en,
    required this.ja,
    required this.ko,
  });

  factory Name.fromJson(Map<String, dynamic> json) {
    return Name(
      en: json['en'],
      ja: json['ja'],
      ko: json['ko'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'en': en,
      'ja': ja,
      'ko': ko,
    };
  }
}

class Series {
  final String en;
  final String ja;
  final String ko;

  factory Series.fromJson(Map<String, dynamic> json) {
    return Series(
      en: json['en'],
      ja: json['ja'],
      ko: json['ko'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'en': en,
      'ja': ja,
      'ko': ko,
    };
  }

  const Series({
    required this.en,
    required this.ja,
    required this.ko,
  });
}
