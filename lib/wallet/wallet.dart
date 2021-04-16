import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:sports_private_pool/api.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

class MyWallet extends StatefulWidget {
  @override
  _MyWalletState createState() => _MyWalletState();
}

class _MyWalletState extends State<MyWallet> {

  Razorpay razorpay;
  TextEditingController textEditingController = new TextEditingController();

  @override
  void initState() {
    super.initState();

    razorpay = new Razorpay();

    razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, handlerPaymentSuccess);
    razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, handlerPaymentFailure);
    razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, handlerExternalWallet);
  }

  @override
  void dispose() {
    super.dispose();
    razorpay.clear();
  }

  void openCheckOut() {
    var options = {
      'key': '$razorpayApi',
      'amount': textEditingController.text,
      'name': 'Envision',
      'description': 'Payment',
      'prefill': {
        'contact': '9876543210',
        'email': 'joey@gmail.com',
      },
      'external': {
        'wallets': ['paytm']
      }
    };

    try {
      razorpay.open(options);
    } catch(e) {
      print(e.toString());
    }

  }

  void handlerPaymentSuccess() {
    print("Payment Success");
  }

  void handlerPaymentFailure() {
    print("Payment Error");
  }

  void handlerExternalWallet() {
    print("External Wallet");
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      body: Column(
        children: [
          TextField(
            controller: textEditingController,
            decoration: InputDecoration(
              hintText: "Enter Amount To add",
            ),
          ),
          SizedBox(height: 12,),
          ElevatedButton(
            child: Text('Add Now'),
            onPressed: () {
              openCheckOut();
            },
          )
        ],
      ),
    ),
    );
  }
}
