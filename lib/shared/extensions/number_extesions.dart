extension NumberExtensions on int {
  String toJapaneseYear() {
    if (this >= 2019) {
      int eraYear = this - 2018;
      return '令和${eraYear == 1 ? '元' : eraYear}年';
    } else if (this >= 1989) {
      int eraYear = this - 1988;
      return '平成${eraYear == 1 ? '元' : eraYear}年';
    } else if (this >= 1926) {
      int eraYear = this - 1925;
      return '昭和${eraYear == 1 ? '元' : eraYear}年';
    } else if (this >= 1912) {
      int eraYear = this - 1911;
      return '大正${eraYear == 1 ? '元' : eraYear}年';
    } else if (this >= 1868) {
      int eraYear = this - 1867;
      return '明治${eraYear == 1 ? '元' : eraYear}年';
    } else {
      return '$this年';
    }
  }
}
