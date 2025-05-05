import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:intl/intl.dart';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../Helper/api_base_helper.dart';
import '../../Helper/constant.dart';
import '../../Helper/session.dart';
import '../../Helper/string.dart';
import '../../Model/Plans/get_plans.dart';
import '../home.dart';

// import 'package:dio/dio.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_stripe/flutter_stripe.dart';
// import 'package:intl/intl.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'dart:developer';
//
// import '../../Helper/apiUtils.dart';
// import '../../Helper/api_base_helper.dart';
// import '../../Helper/constant.dart';
// import '../../Helper/session.dart';
// import '../../Helper/string.dart';
// import '../../Model/Plans/get_plans.dart';
// import '../home.dart';
//
// class StripePaymentHandler {
//   Plans? _selectedPlan;
//   String? mobileNum;
//   late Function() _onSuccess;
//   late BuildContext _context;
//   String? num;
//
//   void startPayment({
//     required BuildContext context,
//     required double amount,
//     required Plans? plan,
//     required String mobile,
//     required Function() onSuccess,
//   }) async {
//     _context = context;
//     _onSuccess = onSuccess;
//     _selectedPlan = plan;
//     mobileNum = mobile;
//
//     await getMobileNum();
//
//     try {
//       // 1. Create payment intent from backend
//       final paymentIntentData =
//           await createPaymentIntent((amount * 100).toInt(), 'INR');
//       if (paymentIntentData == null) {
//         _showErrorMessage('Failed to initiate payment.');
//         return;
//       }
//
//       // 2. Init payment sheet
//       await Stripe.instance.initPaymentSheet(
//         paymentSheetParameters: SetupPaymentSheetParameters(
//           paymentIntentClientSecret: paymentIntentData['client_secret'],
//           merchantDisplayName: appName,
//         ),
//       );
//
//       // 3. Show payment sheet
//       await Stripe.instance.presentPaymentSheet();
//       log("✅ Payment completed");
//
//       buyPlan(paymentIntentData['id'], _context);
//       _onSuccess();
//     } catch (e) {
//       log('❌ Stripe Payment Error: $e');
//       _showErrorMessage("Payment failed or canceled.");
//     }
//   }
//
//   Future<Map<String, dynamic>?> createPaymentIntent(
//       int amount, String currency) async {
//     try {
//       Dio dio = Dio();
//       Options options = Options(
//         headers: {
//           "Content-Type": "application/json",
//         },
//       );
//
//       FormData formData = FormData.fromMap({
//         "amount": amount, // must be integer
//         "currency": "usd", // use a valid Stripe-supported currency
//         "payment_method_types[]": "card",
//       });
//       final response = await dio.post(
//         'https://your-server.com/create-payment-intent',
//         data: formData,
//         options: options,
//       );
//       return response.data;
//     } catch (e) {
//       log('createPaymentIntent error: $e');
//       return null;
//     }
//   }
//
//   Future<void> buyPlan(String? tranId, BuildContext context) async {
//     String? userId;
//
//     var numToUse =
//         (mobileNum != null && mobileNum!.isNotEmpty) ? mobileNum : num;
//     FormData formData = FormData.fromMap({
//       "mobile": numToUse,
//     });
//
//     final verifyResponse =
//         await Dio().post(verifyUserApi.toString(), data: formData);
//     bool error = verifyResponse.data["error"];
//     userId = verifyResponse.data["data"];
//
//     if (error || userId == null) {
//       setsnackbar(
//           "context", verifyResponse.data["message"] ?? "Verification failed");
//       return;
//     }
//
//     String formattedDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
//
//     var body = {
//       'plan_id': _selectedPlan?.id,
//       'partner_id': userId ?? CUR_USERID,
//       'price': _selectedPlan?.price,
//       'is_allowed_offers': _selectedPlan?.allowOffers,
//       'offers_limit': _selectedPlan?.offerLimit,
//       'transaction_id': tranId,
//       'start_date': formattedDate
//     };
//
//     final response = await apiBaseHelper.postAPICall(
//         addPartnerSubscriptionApi, body, context);
//
//     if (response != null) {
//       setsnackbar("Plan purchased successfully!", context);
//     } else {
//       setsnackbar("Something went wrong while buying the plan.", context);
//     }
//   }
//
//   Future<void> getMobileNum() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     num = prefs.getString("MobileFromUSer");
//   }
//
//   void _showErrorMessage(String message) {
//     ScaffoldMessenger.of(_context)
//         .showSnackBar(SnackBar(content: Text(message)));
//   }
// }

import 'package:flutter/services.dart';
import 'package:flutter_stripe/flutter_stripe.dart';

class StripePaymentHandler {
  static String apiBase = 'https://api.stripe.com/v1';
  static String paymentApiUrl =
      '${StripePaymentHandler.apiBase}/payment_intents';
  static String? secret;

  static String? stripePublishableKey;
  static String? stripeCurrency;

  // Variables for plan purchase
  static Plans? _selectedPlan;
  static String? mobileNum;
  static String? num;

  static Future<void> getKeyFromAPI() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    secret = prefs.getString("stripeSecretKey");
    stripePublishableKey = prefs.getString("stripePublishableKey");
    stripeCurrency = prefs.getString("stripeCurrencyCode");
  }

  static Map<String, String> getHeaders() => {
        'Authorization': 'Bearer ${StripePaymentHandler.secret}',
        'Content-Type': 'application/x-www-form-urlencoded',
      };

  static void init({String? stripePublishable, String? stripeSecrate}) {
    Stripe.publishableKey = stripePublishable ?? '';
    StripePaymentHandler.secret = stripeSecrate;

    Stripe.merchantIdentifier = 'merchant.flutter.stripe.test';
    if (Stripe.publishableKey == '') {
      log('Please add stripe publishable key');
    } else if (StripePaymentHandler.secret == null) {
      log('Please add stripe secret key');
    }
  }

  static Future<StripeTransactionResponse> payWithPaymentSheet({
    required int amount,
    required bool isTestEnvironment,
    String? currency,
    String? from,
    BuildContext? context,
    String? awaitedOrderId,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      // Create Payment intent
      final paymentIntent = await createPaymentIntent(
        amount: amount,
        currency: currency,
        from: from,
        context: context,
        metadata: metadata,
      );

      if (paymentIntent == null) {
        return StripeTransactionResponse(
          message: 'Failed to create payment intent',
          success: false,
          status: 'failed',
        );
      }

      // Setting up Payment Sheet
      if (stripeCurrency == 'USD') {
        await Stripe.instance.initPaymentSheet(
          paymentSheetParameters: SetupPaymentSheetParameters(
            paymentIntentClientSecret: paymentIntent['client_secret'],
            allowsDelayedPaymentMethods: true,
            billingDetailsCollectionConfiguration:
                const BillingDetailsCollectionConfiguration(
              address: AddressCollectionMode.full,
              email: CollectionMode.always,
              name: CollectionMode.always,
              phone: CollectionMode.always,
            ),
            customerId: paymentIntent['customer'],
            style: ThemeMode.light,
            merchantDisplayName: appName,
          ),
        );
      } else {
        await Stripe.instance.initPaymentSheet(
          paymentSheetParameters: SetupPaymentSheetParameters(
            paymentIntentClientSecret: paymentIntent['client_secret'],
            allowsDelayedPaymentMethods: true,
            customerId: paymentIntent['customer'],
            style: ThemeMode.light,
            merchantDisplayName: appName,
          ),
        );
      }

      // Open payment sheet
      await Stripe.instance.presentPaymentSheet();

      // Confirm payment
      final response = await Dio().post(
        '${StripePaymentHandler.paymentApiUrl}/${paymentIntent['id']}',
        options: Options(headers: getHeaders()),
      );

      final getdata = Map.from(response.data);
      final statusOfTransaction = getdata['status'];
      log('--stripe response $getdata');

      if (statusOfTransaction == 'succeeded') {
        return StripeTransactionResponse(
          message: 'Transaction successful',
          success: true,
          status: statusOfTransaction,
          num: num,
        );
      } else if (statusOfTransaction == 'pending' ||
          statusOfTransaction == 'captured') {
        return StripeTransactionResponse(
          message: 'Transaction pending',
          success: true,
          status: statusOfTransaction,
          num: num,
        );
      } else {
        return StripeTransactionResponse(
          message: 'Transaction failed',
          success: false,
          status: statusOfTransaction,
        );
      }
    } on PlatformException catch (err) {
      log('Platform issue: $err');
      return getPlatformExceptionErrorResult(err);
    } catch (error) {
      log('Other issue: $error');
      return StripeTransactionResponse(
        message: 'Transaction failed: $error',
        success: false,
        status: 'fail',
      );
    }
  }

  static StripeTransactionResponse getPlatformExceptionErrorResult(err) {
    var message = 'Something went wrong';
    if (err.code == 'cancelled') {
      message = 'Transaction cancelled';
    }

    return StripeTransactionResponse(
      message: message,
      success: false,
      status: 'cancelled',
    );
  }

  static Future<Map<String, dynamic>?> createPaymentIntent({
    required int amount,
    String? currency,
    String? from,
    BuildContext? context,
    String? awaitedOrderID,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final parameter = <String, dynamic>{
        'amount': amount,
        'currency': currency,
        'metadata': metadata,
      };

      final dio = Dio();

      final response = await dio.post(
        StripePaymentHandler.paymentApiUrl,
        data: parameter,
        options: Options(
          headers: StripePaymentHandler.getHeaders(),
        ),
      );

      return Map.from(response.data);
    } catch (e) {
      if (e is DioException) {
        log(e.response!.data.toString());
      }
      log('STRIPE ISSUE ${e is DioException}');
    }
    return null;
  }

  // Function to buy plan after successful payment
  static Future<void> buyPlan(String? tranId, BuildContext context) async {
    String? userId;

    var numToUse =
        (mobileNum != null && mobileNum!.isNotEmpty) ? mobileNum : num;
    FormData formData = FormData.fromMap({
      "mobile": numToUse,
    });

    try {
      final verifyResponse =
          await Dio().post(verifyUserApi.toString(), data: formData);
      bool error = verifyResponse.data["error"];
      userId = verifyResponse.data["data"];

      if (error || userId == null) {
        setsnackbar(
            verifyResponse.data["message"] ?? "Verification failed", context);
        return;
      }

      String formattedDate = DateFormat('yyyy-MM-dd').format(DateTime.now());

      var body = {
        'plan_id': _selectedPlan?.id,
        'partner_id': userId ?? CUR_USERID,
        'price': _selectedPlan?.price,
        'is_allowed_offers': _selectedPlan?.allowOffers,
        'offers_limit': _selectedPlan?.offerLimit,
        'transaction_id': tranId,
        'start_date': formattedDate
      };

      final response = await apiBaseHelper.postAPICall(
          addPartnerSubscriptionApi, body, context);

      if (response != null) {
        setsnackbar("Plan purchased successfully!", context);
      } else {
        setsnackbar("Something went wrong while buying the plan.", context);
      }
    } catch (e) {
      log("Error buying plan: $e");
      setsnackbar("An error occurred. Please try again.", context);
    }
  }

  static Future<void> getMobileNum() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    num = prefs.getString("MobileFromUSer");
  }
}

class StripeTransactionResponse {
  StripeTransactionResponse(
      {this.message, this.success, this.status, this.num});
  final String? message;
  final String? status;
  final String? num;
  bool? success;
}

// Improved function to handle Stripe payment and call buyPlan on success
Future<void> openStripePaymentGateway({
  required BuildContext context,
  required double amount,
  required String number,
  required Plans? plan,
  required Map<String, dynamic> metadata,
  required VoidCallback onSuccess,
  required Function(dynamic message) onError,
}) async {
  // Store plan info and mobile number
  StripePaymentHandler._selectedPlan = plan;
  StripePaymentHandler.mobileNum = number;

  // Get mobile number from SharedPreferences if needed
  await StripePaymentHandler.getMobileNum();

  // Get Stripe credentials
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? stripeSecretKey = prefs.getString("stripeSecretKey");
  String? stripePublishableKey = prefs.getString("stripePublishableKey");
  String? stripeCurrency = prefs.getString("stripeCurrencyCode");

  try {
    // Initialize Stripe
    StripePaymentHandler.init(
      stripePublishable: stripePublishableKey,
      stripeSecrate: stripeSecretKey,
    );

    // Process payment
    final response = await StripePaymentHandler.payWithPaymentSheet(
      amount: (amount * 100).toInt(),
      currency: stripeCurrency,
      isTestEnvironment: true,
      metadata: metadata,
      context: context,
    );

    if (response.success == true && response.status == 'succeeded') {
      // Call buyPlan with the transaction ID from the response
      // Extract transaction ID from metadata or use a placeholder
      String? transactionId = metadata['transaction_id'] ?? response.status;

      // Call buyPlan after successful payment
      await StripePaymentHandler.buyPlan(transactionId, context);

      // Call the success callback
      onSuccess.call();
    } else {
      // Call the error callback
      onError.call(response.message);
    }
  } catch (e) {
    log('ERROR IS $e');
    onError.call("Payment failed: $e");
  }
}

// class StripePaymentHandler {
//   static String apiBase = 'https://api.stripe.com/v1';
//   static String paymentApiUrl = '${StripePaymentHandler.apiBase}/payment_intents';
//   static String? secret;
//
//   static String? stripePublishableKey;
//   static String? stripeCurrency;
//
// getKeyFromAPI()async {
//   SharedPreferences prefs = await SharedPreferences.getInstance();
//   secret = await prefs.getString("stripeSecretKey");
//   stripePublishableKey = await prefs.getString("stripeSecretKey");
//   stripeCurrency = await prefs.getString("stripeCurrencyCode");
//
// }
//   static Map<String, String> headers = {
//     'Authorization': 'Bearer ${StripePaymentHandler.secret}',
//     'Content-Type': 'application/x-www-form-urlencoded',
//   };
//
//   static Map<String, String> getHeaders() => {
//     'Authorization': 'Bearer ${StripePaymentHandler.secret}',
//     'Content-Type': 'application/x-www-form-urlencoded',
//   };
//
//   static void init({String? stripePublishable, String? stripeSecrate}) {
//     Stripe.publishableKey = stripePublishable ?? '';
//     StripePaymentHandler.secret = stripeSecrate;
//
//     Stripe.merchantIdentifier = 'merchant.flut=ter.stripe.testaaa';
//     if (Stripe.publishableKey == '') {
//       log('Please add stripe publishable key');
//     } else if (StripePaymentHandler.secret == null) {
//       log('Please add stripe secret key');
//     }
//   }
//
//   static Future<StripeTransactionResponse> payWithPaymentSheet({
//     required int amount,
//     required bool isTestEnvironment,
//     String? currency,
//     String? from,
//     BuildContext? context,
//     String? awaitedOrderId,
//     Map<String, dynamic>? metadata,
//   }) async {
//     try {
//       //create Payment intent
//
//       // isPaymentGatewayOpen = true;
//       final paymentIntent = await createPaymentIntent(
//         amount: amount,
//         currency: currency,
//         from: from,
//         context: context,
//         metadata: metadata, //{"packageId": 123, "userId": 123}
//         // awaitedOrderID: awaitedOrderId,
//       );
//
//       //setting up Payment Sheet
//       if (stripeCurrency == 'USD') {
//         await Stripe.instance.initPaymentSheet(
//           paymentSheetParameters: SetupPaymentSheetParameters(
//             paymentIntentClientSecret: paymentIntent!['client_secret'],
//             allowsDelayedPaymentMethods: true,
//             billingDetailsCollectionConfiguration:
//             const BillingDetailsCollectionConfiguration(
//               address: AddressCollectionMode.full,
//               email: CollectionMode.always,
//               name: CollectionMode.always,
//               phone: CollectionMode.always,
//             ),
//             customerId: paymentIntent['customer'],
//             style: ThemeMode.light,
//             merchantDisplayName: appName,
//           ),
//         );
//       } else {
//         await Stripe.instance.initPaymentSheet(
//           paymentSheetParameters: SetupPaymentSheetParameters(
//             paymentIntentClientSecret: paymentIntent!['client_secret'],
//             allowsDelayedPaymentMethods: true,
//             customerId: paymentIntent['customer'],
//             style: ThemeMode.light,
//             merchantDisplayName: appName,
//           ),
//         );
//       }
//
//       //open payment sheet
//       await Stripe.instance.presentPaymentSheet();
//
//       //confirm payment
//       final response = await Dio().post(
//         '${StripePaymentHandler.paymentApiUrl}/${paymentIntent['id']}',
//         options: Options(headers: headers),
//       );
//
//       final getdata = Map.from(response.data);
//       final statusOfTransaction = getdata['status'];
//       log('--stripe response $getdata');
//       if (statusOfTransaction == 'succeeded') {
//         // isPaymentGatewayOpen = false;
//
//         return StripeTransactionResponse(
//           message: 'Transaction successful',
//           success: true,
//           status: statusOfTransaction,
//         );
//       } else if (statusOfTransaction == 'pending' ||
//           statusOfTransaction == 'captured') {
//         // isPaymentGatewayOpen = false;
//
//         return StripeTransactionResponse(
//           message: 'Transaction pending',
//           success: true,
//           status: statusOfTransaction,
//         );
//       } else {
//         // isPaymentGatewayOpen = false;
//
//         return StripeTransactionResponse(
//           message: 'Transaction failed',
//           success: false,
//           status: statusOfTransaction,
//         );
//       }
//     } on PlatformException catch (err) {
//       log('Platform issue: $err');
//       // isPaymentGatewayOpen = false;
//
//       return StripePaymentHandler.getPlatformExceptionErrorResult(err);
//     } catch (error) {
//       log('Other issue issue: $error');
//       // isPaymentGatewayOpen = false;
//       return StripeTransactionResponse(
//         message: 'Transaction failed: $error',
//         success: false,
//         status: 'fail',
//       );
//     }
//   }
//
//   static StripeTransactionResponse getPlatformExceptionErrorResult(err) {
//     var message = 'Something went wrong';
//     if (err.code == 'cancelled') {
//       message = 'Transaction cancelled';
//     }
//
//     return StripeTransactionResponse(
//       message: message,
//       success: false,
//       status: 'cancelled',
//     );
//   }
//
//   static Future<Map<String, dynamic>?> createPaymentIntent({
//     required int amount,
//     String? currency,
//     String? from,
//     BuildContext? context,
//     String? awaitedOrderID,
//     Map<String, dynamic>? metadata,
//   }) async {
//     try {
//       final parameter = <String, dynamic>{
//         'amount': amount,
//         'currency': currency,
//         'metadata': metadata,
//       };
//
//       // if (from == 'order') parameter['metadata[order_id]'] = awaitedOrderID;
//
//       final dio = Dio();
//
//       final response = await dio.post(
//         StripePaymentHandler.paymentApiUrl,
//         data: parameter,
//         options: Options(
//           headers: StripePaymentHandler.getHeaders(),
//         ),
//       );
//
//       return Map.from(response.data);
//     } catch (e) {
//       if (e is DioException) {
//         log(e.response!.data.toString());
//       }
//
//       log('STRIPE ISSUE ${e is DioException}');
//     }
//     return null;
//   }
// }
//
// class StripeTransactionResponse {
//   StripeTransactionResponse({this.message, this.success, this.status,this.num});
//   final String? message;
//   final String? status;
//   final String? num;
//   bool? success;
// }
// Future<void> openStripePaymentGateway({
//   required double amount,
//   required String number,
//   required Plans? plan,
//   required Map<String, dynamic> metadata,
//   required VoidCallback onSuccess,
//   required Function(dynamic message) onError,
// }) async {
//
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//    String? StripeSecretKey = await prefs.getString("stripeSecretKey");
//     String?  stripePublishableKey = await prefs.getString("stripePublishableKey");
//     String?  stripeCurrency = await prefs.getString("stripeCurrencyCode");
//
//
//   try {
//     StripePaymentHandler.init(
//       stripePublishable:stripePublishableKey,
//       stripeSecrate:StripeSecretKey,
//     );
//
//     final response = await StripePaymentHandler.payWithPaymentSheet(
//       amount: (amount * 100).toInt(),
//       currency: stripeCurrency,
//       isTestEnvironment: true,
//       metadata: metadata,
//     );
//
//     if (response.status == 'succeeded') {
//
//       onSuccess.call();
//     } else {
//       onError.call(response.message);
//     }
//   } catch (e) {
//     log('ERROR IS $e');
//   }
// }
