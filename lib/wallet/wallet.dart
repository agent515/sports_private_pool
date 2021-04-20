import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sports_private_pool/wallet/Payment_Screen.dart';

class MyWallet extends StatefulWidget {
  @override
  _MyWalletState createState() => _MyWalletState();
}

class _MyWalletState extends State<MyWallet> {

  TextEditingController _amountController = new TextEditingController();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      body: Padding(
        padding: EdgeInsets.all(30),
        child: Column(
          children: [
            // Text(
            //   '₹ ' + loggedInUserData['purse'].toString(),
            //   style: TextStyle(
            //     color: Colors.white,
            //     fontWeight: FontWeight.bold,
            //   ),
            // ),
            // SizedBox(height: 12,),
            TextField(
              controller: _amountController,
              decoration: InputDecoration(
                hintText: "Enter Amount To add",
              ),
            ),
            SizedBox(height: 12,),
            ElevatedButton(
              child: Text('Add Now'),
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(builder: (context) => PaymentScreen(amount: _amountController.text,)));
              },
            )
          ],
        ),
      )
    ),
    );
  }
}
