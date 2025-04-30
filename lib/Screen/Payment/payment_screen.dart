import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:intl/intl.dart';

import 'package:flutter/material.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../Helper/api_base_helper.dart';
import '../../Helper/constant.dart';
import '../../Helper/session.dart';
import '../../Helper/string.dart';
import '../../Model/Plans/get_plans.dart';
import '../home.dart';

class RazorpayPaymentHandler {
  Plans? _selectedPlan;
  String? mobileNum;

  late Razorpay _razorpay;
  late Function() _onSuccess;
  late BuildContext _context;
  String? num;

  void startPayment({
    required BuildContext context,
    required double amount,
    required Plans? plan,
    required String mobile,
    required Function() onSuccess,
  }) {
    _context = context;
    _onSuccess = onSuccess;
    _selectedPlan = plan;
    mobileNum = mobile;
    _initializeRazorpay();
    _openCheckout(amount);
  }

  void _initializeRazorpay() {
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  void _openCheckout(
    double amount,
  ) {
    final amountInPaise = (amount * 100).toInt();

    var options = {
      'key': 'rzp_test_AOKSsmqOtoTLcz',
      'amount': amountInPaise,
      'name': appName,
      'description': '$appName Subscription',
      'prefill': {'contact': '', 'email': ''},
      'external': {
        'wallets': ['paytm']
      }
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      log('Error: ${e.toString()}');
      _showErrorMessage('Something went wrong. Please try again.');
    }
  }

  Future<void> buyPlan(String? tranId, context) async {
    print("wsedrtfbghunyjmk,l ");
    String? userId;

    log("📞 Mobile Number:e  $mobileNumber");
    log("📞 Mobile Number: $mobileNum");
    log("📞 Mobile Number: $num");

    // First API call (wait until response comes)
if(mobileNum!="" &&mobileNum!=null){
  var numToUse = (mobileNum != null && mobileNum!.isNotEmpty) ? mobileNum : num;

  FormData formData = FormData.fromMap({
    "mobile": numToUse,
  });
  Dio dio = Dio();
// Call API using Dio
  final response = await dio.post(verifyUserApi.toString(), data: formData, options: Options(
    headers: {
      'Content-Type': 'multipart/form-data',
      // Do not include 'Content-Length'
    },
  ),);

  // Handle response
  bool error = response.data["error"];
  String? msg = response.data["message"];
  userId = response.data["data"];
  if (error || userId == null) {
    setsnackbar(context, msg ?? "Something went wrong");
    return;
  }
}

    // Stop if there's an error

    DateTime today = DateTime.now();
    String formattedDate = DateFormat('yyyy-MM-dd').format(today);
    print(formattedDate); // e.g., 12 Apr 2025

    // Second API call only after the first is successful
    var body = {
      'plan_id': _selectedPlan?.id,
      'partner_id': userId!=null ?userId:CUR_USERID,
      'price': _selectedPlan?.price!,
      'is_allowed_offers': _selectedPlan?.allowOffers!,
      'offers_limit': _selectedPlan?.offerLimit,
      'transaction_id': tranId,
      'start_date': formattedDate
    };

    final response = await apiBaseHelper.postAPICall(
        addPartnerSubscriptionApi, body, context);

    // Optionally handle the second response
    if (response != null) {
      // context.read<MembershipPlanBloc>().add(FetchMembershipPlan());
      setsnackbar(
        context,
        "Plan purchased successfully!",
      );
    } else {
      setsnackbar(context, "Something went wrong while buying the plan.");
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response)async  {
    log("✅ Payment succeeded");
    log("Payment ID: ${response.paymentId}");
    log("Order ID: ${response.orderId}");
    log("Signature: ${response.signature}");
    log("data: ${response.data}");
    log("data: ${response.data.runtimeType}");
    await getMobileNum();
    log("📞 Mobile Number: $mobileNumber");

    buyPlan(response.paymentId, _context);

    _onSuccess();
    _disposeRazorpay();
  }
getMobileNum()async{
  SharedPreferences prefs = await SharedPreferences.getInstance();
   num =  prefs.getString("MobileFromUSer");
}
  void _handlePaymentError(PaymentFailureResponse response) {
    log("❌ Payment failed");
    log("Code: ${response.code}");
    log("Message: ${response.message}");
    _disposeRazorpay();
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    log("💳 External Wallet Selected: ${response.walletName}");
    _disposeRazorpay();
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(_context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _disposeRazorpay() {
    _razorpay.clear();
  }
}
