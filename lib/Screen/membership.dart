import 'dart:async';
import 'dart:ui';
import 'package:erestro/Model/Plans/get_plans.dart';
import 'package:erestro/Screen/Payment/success_page.dart';
import 'package:erestro/Screen/Payment/payment_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Helper/session.dart';
import '../Helper/string.dart';
import 'home.dart';

class MembershipScreen extends StatefulWidget {
  final String mobile;
  const MembershipScreen({Key? key, required this.mobile}) : super(key: key);

  @override
  State<MembershipScreen> createState() => _MembershipScreenState();
}

class _MembershipScreenState extends State<MembershipScreen> {
  bool _isNetworkAvail = true;
  List<Plans> planList = [];
  List<Plans> planActiveList = [];
  String? jwtToken;

  @override
  void initState() {
    getPlans();
    super.initState();
  }

  @override
  void dispose() {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.white,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
    );
    super.dispose();
  }

  getPlans() async {
    _isNetworkAvail = await isNetworkAvailable();
    if (_isNetworkAvail) {
      try {
        jwtToken = await getPrefrence(token);
        if (jwtToken != null) {
          var parameter = {};

          if (jwtToken != null && jwtToken!.isNotEmpty) {
            parameter['partner_id'] = CUR_USERID;
          }

          apiBaseHelper
              .postAPICall(getPlansApi, parameter, context)
              .then((getdata) async {
            bool error = getdata["error"];
            String msg = getdata["message"];

            if (!error) {
              var data = getdata["data"];
              planActiveList =
                  (data as List).map((data) => Plans.fromJson(data)).toList();
            } else {
              setsnackbar(msg, context);
            }
            setState(
              () {},
            );
          });
        }
        var parameter = {};

        apiBaseHelper
            .postAPICall(getPlansApi, parameter, context)
            .then((getdata) async {
          bool error = getdata["error"];
          String msg = getdata["message"];

          if (!error) {
            var data = getdata["data"];
            planList =
                (data as List).map((data) => Plans.fromJson(data)).toList();
          } else {
            setsnackbar(msg, context);
          }
          setState(
            () {},
          );
        });
      } on TimeoutException catch (_) {
        setsnackbar(
          getTranslated(context, "somethingMSg")!,
          context,
        );
      }
    } else {
      setState(
        () {
          _isNetworkAvail = false;
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    planList.sort((a, b) {
      final aIsActive = planActiveList.any((active) => active.id == a.id);
      final bIsActive = planActiveList.any((active) => active.id == b.id);
      return bIsActive.toString().compareTo(aIsActive.toString());
    });
    return AnnotatedRegion<SystemUiOverlayStyle>(
        value: const SystemUiOverlayStyle(
          statusBarColor: Color(0xFF1B1C3D), // Set custom color
          statusBarIconBrightness: Brightness.light, // for white icons
          statusBarBrightness: Brightness.dark,
        ),
        child: Scaffold(
            backgroundColor: const Color(0xFF1B1C3D),
            // backgroundColor: const Color(0xFF0D68E0),
            body: Container(
                child: Stack(children: [
              // Glowing Circles Behind Card
              Positioned(
                top: 150,
                right: -20,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        Colors.orange.withOpacity(0.8),
                        Colors.deepOrange.withOpacity(0.8),
                        Colors.pink.withOpacity(0.5),
                      ],
                      center: Alignment(-0.4, -0.4),
                      radius: 0.9,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.deepOrange.withOpacity(0.3),
                        blurRadius: 40,
                        spreadRadius: 10,
                      ),
                    ],
                  ),
                ),
              ),

              Positioned(
                top: 550,
                left: -20,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        Colors.orange.withOpacity(0.8),
                        Colors.deepOrange.withOpacity(0.7),
                        Colors.pink.withOpacity(0.5),
                      ],
                      center: Alignment(-0.5, -0.5),
                      radius: 0.9,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.deepOrange.withOpacity(0.3),
                        blurRadius: 40,
                        spreadRadius: 10,
                      ),
                    ],
                  ),
                ),
              ),

              // Card and Info
              Center(
                child: Padding(
                  padding:
                      const EdgeInsets.only(top: 48.0, left: 18, right: 18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          const Expanded(
                            child: Text(
                              'Membership\nPlans',
                              style: TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          jwtToken != null
                              ? IconButton(
                                  icon: const Icon(Icons.close,
                                      color: Colors.white),
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                )
                              : SizedBox(),
                        ],
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Select a Membership Option',
                        style: TextStyle(color: Colors.white, fontSize: 14),
                      ),
                      const SizedBox(height: 10),
                      Expanded(
                        child: ListView.builder(
                          shrinkWrap: true,
                          padding: const EdgeInsetsDirectional.only(
                            bottom: 25,
                          ),
                          itemCount: planList.length,
                          itemBuilder: (context, index) {
                            var plans = planList[index];
                            bool isActive = planActiveList
                                .any((activePlan) => activePlan.id == plans.id);
                            return planList.isEmpty
                                ? Container()
                                : MembershipCard(
                                    token: jwtToken,
                                    plan: plans,
                                    mobile: widget.mobile,
                                    offersAllowed: plans.allowOffers,
                                    title: plans.name!,
                                    duration: plans.duration,
                                    offerLimit: plans.offerLimit,
                                    created: plans.dateCreated,
                                    iconColor: Colors.orange,
                                    descText: plans.description,
                                    status: plans.status,
                                    newPrice: plans.price!,
                                    isTakenPlan: isActive,
                                    onPlanUpdated: getPlans,
                                  );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ]))));
  }
}

class MembershipCard extends StatelessWidget {
  Plans plan;
  final String title;
  final String? mobile;
  final Color iconColor;
  final String? status;
  final String? descText;
  final String? duration;
  final String? offerLimit;
  final String? offersAllowed;
  final String? created;

  final String newPrice;
  final bool isTakenPlan;
  final String? token;
  final VoidCallback? onPlanUpdated;

  MembershipCard({
    Key? key,
    required this.plan,
    this.token,
    required this.title,
    required this.onPlanUpdated,
    this.isTakenPlan = false,
    this.mobile,
    required this.duration,
    required this.offerLimit,
    required this.offersAllowed,
    required this.created,
    required this.iconColor,
    required this.descText,
    this.status,
    required this.newPrice,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Stack(
        children: [
          Padding(
            padding: EdgeInsets.only(top: 18.0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                child: Container(
                  // width: 320,
                  // height: 340,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: isTakenPlan
                        ? Colors.orangeAccent.withOpacity(0.09)
                        : Colors.white.withOpacity(0.08),
                    border: Border.all(
                        width: 2,
                        color: isTakenPlan
                            ? Colors.orangeAccent.withOpacity(0.8)
                            : Colors.white.withOpacity(0.2)),
                  ),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // same content inside card...
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            // crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                title,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    fontSize: 20),
                              ),
                              status == "1"
                                  ? Container(
                                      margin: const EdgeInsets.only(top: 4),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 7),
                                      decoration: BoxDecoration(
                                        color: Colors.green,
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                      child: Text(
                                        "Active",
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    )
                                  : SizedBox(),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconTextRow(
                              icon: Icons.attach_money,
                              label: "Price",
                              value: newPrice,
                              isIcon: false),
                          SizedBox(
                            height: 5,
                          ),
                          IconTextRow(
                              icon: Icons.timer,
                              label: "Duration",
                              value: duration!,
                              isIcon: false),
                          SizedBox(
                            height: 5,
                          ),
                          IconTextRow(
                              icon: Icons.timer,
                              label: "Offers Allowed",
                              value: offersAllowed!,
                              isIcon: true),
                          SizedBox(
                            height: 5,
                          ),
                          offerLimit != ""
                              ? IconTextRow(
                                  icon: Icons.local_offer,
                                  label: "Offer Limits",
                                  value: offerLimit!,
                                  isIcon: false)
                              : SizedBox(),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        descText!,
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                        ),
                      ),

                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            " \$ ${newPrice}",
                            style: const TextStyle(
                              fontSize: 18,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          isTakenPlan
                              ? SizedBox()
                              : Container(
                                  decoration: BoxDecoration(
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(
                                            0.15), // soft black shadow
                                        blurRadius: 10,
                                        spreadRadius: 1,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.orange,
                                      elevation: 0, // no internal shadow
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(30),
                                      ),
                                    ),
                                    onPressed: () async {
                                      final RazorpayPaymentHandler
                                          _paymentHandler =
                                          RazorpayPaymentHandler();

                                      _paymentHandler.startPayment(
                                        context: context,
                                        amount:
                                            double.tryParse(plan.price!) ?? 0.0,
                                        mobile: mobile!,
                                        onSuccess: () async {
                                          if (token == null) {
                                            // If token is null, navigate and don't return
                                            Navigator.pushReplacement(
                                              context,
                                              CupertinoPageRoute(
                                                builder: (context) =>
                                                    PaymentSuccessScreen(),
                                              ),
                                            );
                                          } else {
                                            // If token exists, push and wait for result
                                            final result = await Navigator.push(
                                              context,
                                              CupertinoPageRoute(
                                                builder: (context) =>
                                                    PaymentSuccessScreen(),
                                              ),
                                            );

                                            if (result == true) {
                                              // 👇 Call your function to update list here
                                              if (onPlanUpdated != null) {
                                                onPlanUpdated!();
                                              } // or setState or Bloc/Cubit event
                                            }
                                          }
                                        },
                                        plan: plan,
                                      );
                                    },
                                    child: Text(
                                      token == null
                                          ? 'Buy Now'
                                          : isTakenPlan == false
                                              ? 'Upgrade Now'
                                              : '', // or any other fallback
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        "Created on: $created",
                        style: TextStyle(
                            color: Colors.grey.shade500, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          isTakenPlan
              ? Positioned(
                  top: 5,
                  left: 20,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.orangeAccent.shade400,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      "Active Subscription",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                )
              : Positioned(
                  top: 5,
                  left: 20,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade400,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      "Available plans",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
        ],
      ),
    );
  }
}

class IconTextRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool isIcon;

  const IconTextRow({
    super.key,
    required this.icon,
    required this.isIcon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          child: Row(
            children: [
              Container(
                  padding: const EdgeInsets.all(5),
                  decoration: const BoxDecoration(
                    color: Color(0xFFF0F1F3), // light grey background
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, size: 15, color: Colors.orangeAccent)),
              const SizedBox(width: 4),
              Text(
                label,
                style: const TextStyle(fontSize: 15, color: Colors.white),
              ),
            ],
          ),
        ),
        const SizedBox(height: 2),
        isIcon
            ? (value == "0"
                ? Icon(Icons.check, size: 20, color: Colors.green)
                : Icon(Icons.close, size: 20, color: Colors.orangeAccent))
            : Text(
                value,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
      ],
    );
  }
}
