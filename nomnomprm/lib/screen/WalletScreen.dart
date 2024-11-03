import 'dart:convert';
import 'package:NomDeli/model/transaction_model.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class WalletPage extends StatefulWidget {
  final String userId;

  WalletPage({required this.userId});

  @override
  _WalletPageState createState() => _WalletPageState();
}

void showAwesomeSnackBar(
    BuildContext context, String title, String message, ContentType type) {
  final snackBar = SnackBar(
    elevation: 0,
    behavior: SnackBarBehavior.floating,
    backgroundColor: Colors.transparent,
    content: AwesomeSnackbarContent(
      title: title,
      message: message,
      contentType: type,
    ),
  );

  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}

class _WalletPageState extends State<WalletPage> {
  List<Transaction> transactions = [];
  bool isLoading = false;
  TextEditingController amountController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  int userBalance = 0; // User balance variable as int

  @override
  void initState() {
    super.initState();
    fetchUserData(); // Fetch user data on init
    fetchTransactions();
  }

  @override
  void dispose() {
    amountController.dispose();
    super.dispose();
  }

  Future<void> fetchTransactions() async {
    setState(() {
      isLoading = true;
    });

    try {
      var url = Uri.parse(
          'https://nomnom-food-delivery-g2f4f9ffare9axhg.eastasia-01.azurewebsites.net/api/v1/transaction?userId=${widget.userId}');
      var response = await http.get(url);

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        List<Transaction> fetchedTransactions = [];

        for (var item in data['data']) {
          fetchedTransactions.add(Transaction.fromJson(item));
        }

        fetchedTransactions.sort((a, b) {
          var dateComparison = b.createdDate.compareTo(a.createdDate);
          if (dateComparison == 0) {
            return b.creatTime.compareTo(a.creatTime);
          }
          return dateComparison;
        });

        setState(() {
          transactions = fetchedTransactions;
          isLoading = false;
        });
      } else {
        print('Failed to load transactions');
        showAwesomeSnackBar(context, 'Error', 'Failed to load transactions',
            ContentType.failure);
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      showAwesomeSnackBar(
          context, 'Error', 'Failed to load transactions', ContentType.failure);
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> fetchUserData() async {
    try {
      var url = Uri.parse(
          'https://nomnom-food-delivery-g2f4f9ffare9axhg.eastasia-01.azurewebsites.net/api/v1/user?userId=${widget.userId}');
      var response = await http.get(url);

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        var userData = data['data'][0];
        setState(() {
          userBalance = userData['balance'];
        });
      } else {
        showAwesomeSnackBar(
            context, 'Error', 'Failed to load user data', ContentType.failure);
      }
    } catch (e) {
      showAwesomeSnackBar(
          context, 'Error', 'Failed to load user data', ContentType.failure);
    }
  }

  Future<void> _refreshTransactions() async {
    await fetchTransactions();
  }

  Future<void> handlePayment(String amount) async {
    try {
      var url = Uri.parse(
          'https://nomnom-food-delivery-g2f4f9ffare9axhg.eastasia-01.azurewebsites.net/api/v1/payment/payOs');
      var body = jsonEncode({
        'userId': widget.userId,
        'amount': int.parse(amount),
      });
      var headers = {
        'accept': '*/*',
        'Content-Type': 'application/json',
      };

      var response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 200) {
        var responseData = jsonDecode(response.body);
        String paymentUrl =
            responseData['url'].trim(); // Remove leading/trailing whitespace
        final Uri _url = Uri.parse(paymentUrl);

        // Mở URL trong ứng dụng bên ngoài
        // ignore: unused_local_variable
        bool launched =
            await launchUrl(_url, mode: LaunchMode.externalApplication);

        // if (!launched) {
        //   ScaffoldMessenger.of(context).showSnackBar(

        //   );
        // }

        // Cập nhật số dư và lấy lại giao dịch sau khi mở URL thanh toán
        // await updateBalance(int.parse(amount));
        await fetchTransactions();
      } else {
        showAwesomeSnackBar(context, 'Error', 'Failed to load Payment url', ContentType.failure);
      }
    } catch (e) {
      showAwesomeSnackBar(context, 'Error', 'Failed to load Payment url', ContentType.failure);
    }
  }

  String? validateAmount(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter an amount';
    }

    value = value.replaceAll(RegExp(r'[^0-9]'), '');

    int amount;
    try {
      amount = int.parse(value);
    } catch (e) {
      return 'Invalid amount';
    }

    if (amount < 2000 || amount % 1000 != 0) {
      return 'Amount must be at least 2,000 and a multiple of 1000';
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Wallet'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _refreshTransactions,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 16),
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Available Balance',
                      style: TextStyle(color: Colors.grey, fontSize: 16),
                    ),
                    SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '$userBalance NC', // Display user balance here
                          style: TextStyle(
                              fontSize: 32, fontWeight: FontWeight.bold),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: Text('Enter Amount'),
                                  content: Form(
                                    key: _formKey,
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        TextFormField(
                                          controller: amountController,
                                          keyboardType:
                                              TextInputType.numberWithOptions(
                                                  decimal: true),
                                          validator: validateAmount,
                                          decoration: InputDecoration(
                                            hintText: 'Enter amount',
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12.0),
                                              borderSide: BorderSide(
                                                  color: Colors.grey),
                                            ),
                                          ),
                                        ),
                                        SizedBox(height: 8),
                                        ElevatedButton(
                                          onPressed: () {
                                            if (_formKey.currentState!
                                                .validate()) {
                                              String amount =
                                                  amountController.text.trim();
                                              // Gọi hàm handlePayment và chờ nó hoàn thành
                                              handlePayment(amount).then((_) {
                                                Navigator.pop(
                                                    context); // Đóng dialog sau khi thanh toán
                                              });
                                            }
                                          },
                                          child: Text('Deposit'),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                          child: Text('Deposit'),
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18.0),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 24),
              Text(
                'Latest Transactions',
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
              SizedBox(height: 8),
              Expanded(
                child: isLoading
                    ? Center(child: CircularProgressIndicator())
                    : transactions.isEmpty
                        ? Center(child: Text('No transactions found.'))
                        : ListView.builder(
                            itemCount: transactions.length,
                            itemBuilder: (context, index) {
                              return TransactionTile(
                                transaction: transactions[index],
                              );
                            },
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class TransactionTile extends StatelessWidget {
  final Transaction transaction;

  const TransactionTile({required this.transaction});

  @override
  Widget build(BuildContext context) {
    String statusText = '';
    String transactionType = '';
    String amountUnit = ''; // Đơn vị tiền tệ tùy thuộc vào loại giao dịch

    TextStyle defaultTextStyle = TextStyle(fontWeight: FontWeight.bold);
    TextStyle successTextStyle =
        TextStyle(fontWeight: FontWeight.bold, color: Colors.green);
    TextStyle pendingTextStyle =
        TextStyle(fontWeight: FontWeight.bold, color: Colors.yellow);
    TextStyle failedTextStyle =
        TextStyle(fontWeight: FontWeight.bold, color: Colors.red);
    TextStyle unknownTextStyle =
        TextStyle(fontWeight: FontWeight.bold, color: Colors.grey);

    // Xử lý status
    switch (transaction.status) {
      case 1:
        statusText = 'Success';
        break;
      case 2:
        statusText = 'Pending';
        break;
      case 3:
        statusText = 'Canceled';
        break;
      default:
        statusText = 'Failed';
    }

    // Xử lý transaction type và đơn vị tiền tệ
    switch (transaction.type) {
      case 1:
        transactionType = 'OutCome';
        amountUnit = 'Nom Coin'; // Đơn vị cho OutCome
        break;
      case 2:
        transactionType = 'Income';
        amountUnit = 'VNĐ'; // Đơn vị cho Income
        break;
      default:
        transactionType = 'Unknown';
        amountUnit = 'VNĐ'; // Đơn vị mặc định
    }

    // Định dạng ngày và giờ
    DateTime createdDate = DateTime.parse(transaction.createdDate);
    String formattedDate = DateFormat('dd/MM/yyyy').format(createdDate);

    DateTime createdTime =
        DateTime.parse('2000-01-01T${transaction.creatTime}');
    String formattedTime = DateFormat('HH:mm').format(createdTime);

    return Container(
      margin: EdgeInsets.symmetric(
          vertical: 8.0), // Thêm khoảng cách giữa các giao dịch
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300), // Đặt màu khung
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 4,
            spreadRadius: 1,
            offset: Offset(2, 2), // Đặt hướng bóng
          ),
        ],
      ),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.blue.shade100,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(Icons.shopping_bag, color: Colors.blue),
        ),
        title: Text(transaction.transactionId, style: defaultTextStyle),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('$formattedDate $formattedTime', style: defaultTextStyle),
            Text(
              'Amount: ${transaction.amount.toStringAsFixed(0)} $amountUnit',
              style: defaultTextStyle,
            ),
            Text('Type: $transactionType', style: defaultTextStyle),
            Text('Status: ',
                style: defaultTextStyle.copyWith(fontWeight: FontWeight.bold)),
            Text(
              statusText,
              style: statusText == 'Success'
                  ? successTextStyle
                  : statusText == 'Pending'
                      ? pendingTextStyle
                      : statusText == 'Failed'
                          ? failedTextStyle
                          : unknownTextStyle,
            ),
          ],
        ),
      ),
    );
  }
}

