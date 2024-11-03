class Transaction {
  final String transactionId;
  final String userId;
  final double amount;
  final int type;
  final String creatTime;
  final String createdDate;
  final int status;

  Transaction({
    required this.transactionId,
    required this.userId,
    required this.amount,
    required this.type,
    required this.creatTime,
    required this.createdDate,
    required this.status,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
  return Transaction(
    transactionId: json['transationId'] ?? '',
    userId: json['userId'] ?? '',
    amount: json['amount']?.toDouble() ?? 0.0,
    type: json['type'] ?? 0,
    creatTime: json['creatTime'] ?? '',
    createdDate: json['createdDate'] ?? '',
    status: json['status'] ?? 0,
  );
}

}