class Dateandtimeconverter {
  static Map<String, String> getDateAndTime({required String dateAndTime}) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Jun',
      'July',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final parsedDateAndTime = DateTime.tryParse(dateAndTime);
    if (parsedDateAndTime == null) {
      return {'date': 'Not Defined', 'time': 'Not Defined'};
    }
    final date = parsedDateAndTime.day.toString();
    final month = months[parsedDateAndTime.month - 1];
    final time = '${parsedDateAndTime.hour} : ${parsedDateAndTime.minute}';
    return {'date': "$month $date", 'time': time};
  }
}
