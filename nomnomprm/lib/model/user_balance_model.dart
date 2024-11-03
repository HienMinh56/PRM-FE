class UserBalance {
  final String userId;
  final String name;
  final String userName;
  final int balance;

  UserBalance({
    required this.userId,
    required this.name,
    required this.userName,
    required this.balance,
  });

  factory UserBalance.fromJson(Map<String, dynamic> json) {
    return UserBalance(
      userId: json['userId'],
      name: json['name'],
      userName: json['userName'],
      balance: json['balance'],
    );
  }
}
