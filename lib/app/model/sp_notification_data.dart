class SPNotificationList {
  String date;
  List<SPNotificationData> messages;

  SPNotificationList({
    required this.date,
    required this.messages,
  });

  factory SPNotificationList.fromJson(Map<String, dynamic> json) {
    var messageList = json['messages'] as List;
    List<SPNotificationData> messages =
        messageList.map((i) => SPNotificationData.fromJson(i)).toList();

    return SPNotificationList(
      date: json['date_category'] ?? "",
      messages: messages,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date_category': date,
      'messages': messages.map((v) => v.toJson()).toList(),
    };
  }
}

class SPNotificationData {
  String message;
  String title;
  String image;
  String time;

  SPNotificationData({
    required this.message,
    required this.title,
    required this.image,
    required this.time,
  });

  factory SPNotificationData.fromJson(Map<String, dynamic> json) {
    return SPNotificationData(
      message: json['message'] ?? "",
      title: json['title'] ?? "",
      image: json['image'] ?? "",
      time: json['time'] ?? "",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'title': title,
      'image': image,
      'time': time,
    };
  }
}
