// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart'; // For date formatting
// import '../../Helper/Color.dart';
// import '../../Helper/session.dart';
//
// class AddUpdateOffers extends StatefulWidget {
//   const AddUpdateOffers({super.key});
//
//   @override
//   State<AddUpdateOffers> createState() => _AddUpdateOffersState();
// }
//
// class _AddUpdateOffersState extends State<AddUpdateOffers> {
//   List<String> typeList = ["Select Type", "Default", "Category", "Product"];
//   TextEditingController offerTypeController = TextEditingController(text: "Select Type");
//
//   bool _isDropdownOpen = false;
//
//   DateTime? selectedStartDate;
//   DateTime? selectedEndDate;
//
//   TextEditingController startDateController = TextEditingController();
//   TextEditingController endDateController = TextEditingController();
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Offers Management'),
//         backgroundColor: Colors.white,
//         foregroundColor: Colors.black,
//         elevation: 0,
//       ),
//       body: Padding(
//         padding: const EdgeInsets.symmetric(horizontal: 18.0),
//         child: ListView(
//           children: [
//             const SizedBox(height: 16),
//
//             // Offer Type Label
//             Text(
//               getTranslated(context, "type") ?? "Type",
//               style: const TextStyle(
//                 fontSize: 16,
//                 color: black,
//                 fontWeight: FontWeight.w500,
//               ),
//             ),
//             const SizedBox(height: 10),
//
//             // Offer Type Dropdown
//             Container(
//               decoration: BoxDecoration(
//                 borderRadius: BorderRadius.circular(5),
//                 color: white,
//                 border: Border.all(color: backgroun2, width: 1),
//               ),
//               margin: const EdgeInsetsDirectional.only(bottom: 10.0, end: 10.0),
//               width: width,
//               child: InkWell(
//                 onTap: () {
//                   setState(() {
//                     _isDropdownOpen = !_isDropdownOpen;
//                   });
//                   FocusScope.of(context).unfocus();
//                 },
//                 child: Stack(
//                   children: [
//                     TextFormField(
//                       enabled: false,
//                       controller: offerTypeController,
//                       style: const TextStyle(color: black),
//                       decoration: InputDecoration(
//                         border: InputBorder.none,
//                         isDense: true,
//                         contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
//                         suffixIcon: Icon(
//                           _isDropdownOpen ? Icons.arrow_drop_up : Icons.arrow_drop_down,
//                           color: black,
//                         ),
//                       ),
//                       validator: (val) => validateField(val, context),
//                       autovalidateMode: AutovalidateMode.onUserInteraction,
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//
//             if (_isDropdownOpen)
//               Container(
//                 decoration: BoxDecoration(
//                   borderRadius: BorderRadius.circular(5),
//                   color: white,
//                   border: Border.all(color: backgroun2, width: 1),
//                   boxShadow: [
//                     BoxShadow(
//                       color: Colors.grey.withOpacity(0.2),
//                       spreadRadius: 1,
//                       blurRadius: 3,
//                       offset: const Offset(0, 2),
//                     ),
//                   ],
//                 ),
//                 width: width - 28,
//                 child: ListView.builder(
//                   shrinkWrap: true,
//                   physics: const ClampingScrollPhysics(),
//                   itemCount: typeList.length,
//                   itemBuilder: (context, index) {
//                     return InkWell(
//                       onTap: () {
//                         setState(() {
//                           offerTypeController.text = typeList[index];
//                           _isDropdownOpen = false;
//                         });
//                       },
//                       child: Container(
//                         padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
//                         decoration: BoxDecoration(
//                           border: index < typeList.length - 1
//                               ? const Border(bottom: BorderSide(color: backgroun2, width: 0.5))
//                               : null,
//                         ),
//                         child: Text(
//                           typeList[index],
//                           style: const TextStyle(color: black, fontSize: 14),
//                         ),
//                       ),
//                     );
//                   },
//                 ),
//               ),
//
//             const SizedBox(height: 16),
//
//             // Start Date Field
//             Text(
//               getTranslated(context, "start_date") ?? "Start Date",
//               style: const TextStyle(fontSize: 16, color: black, fontWeight: FontWeight.w500),
//             ),
//             const SizedBox(height: 10),
//             buildDatePickerField(
//               controller: startDateController,
//               onTap: () async {
//                 final pickedDate = await showDatePicker(
//                   context: context,
//                   initialDate: selectedStartDate ?? DateTime.now(),
//                   firstDate: DateTime(2000),
//                   lastDate: DateTime(2100),
//                 );
//                 if (pickedDate != null) {
//                   setState(() {
//                     selectedStartDate = pickedDate;
//                     startDateController.text = DateFormat('dd/MM/yyyy').format(pickedDate);
//                   });
//                 }
//               },
//             ),
//
//             const SizedBox(height: 16),
//
//             // End Date Field
//             Text(
//               getTranslated(context, "end_date") ?? "End Date",
//               style: const TextStyle(fontSize: 16, color: black, fontWeight: FontWeight.w500),
//             ),
//             const SizedBox(height: 10),
//             buildDatePickerField(
//               controller: endDateController,
//               onTap: () async {
//                 final pickedDate = await showDatePicker(
//                   context: context,
//                   initialDate: selectedEndDate ?? DateTime.now(),
//                   firstDate: DateTime(2000),
//                   lastDate: DateTime(2100),
//                 );
//                 if (pickedDate != null) {
//                   setState(() {
//                     selectedEndDate = pickedDate;
//                     endDateController.text = DateFormat('dd/MM/yyyy').format(pickedDate);
//                   });
//                 }
//               },
//             ),
//             const SizedBox(height: 10),
//            Container(
//              child: Column(
//                crossAxisAlignment: CrossAxisAlignment.start,
//                children: [
//                  Text(
//                    getTranslated(context, "Offer Image *") ?? "Offer Image *",
//                    style: const TextStyle(fontSize: 16, color: black, fontWeight: FontWeight.w500),
//                  ),
//                  SizedBox(height: 10,),
//                  Container(
//                    height: 40,
//                    // width: 50,
//
//                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(5),     color: primary,),
//                    child: Center(child: Text("Upload Image", style: const TextStyle(fontSize: 16, color: white, fontWeight: FontWeight.w500))),
//                  )
//                ],
//              ),
//            )   ,
//             const SizedBox(height: 10),
//            Container(
//              child: Column(
//                crossAxisAlignment: CrossAxisAlignment.start,
//                children: [
//                  Text(
//                    getTranslated(context, "bannerimage*") ?? "Offer Image *",
//                    style: const TextStyle(fontSize: 16, color: black, fontWeight: FontWeight.w500),
//                  ),
//                  SizedBox(height: 10,),
//                  Container(
//                    height: 40,
//                    // width: 50,
//
//                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(5),     color: primary,),
//                    child: Center(child: Text("Upload Image", style: const TextStyle(fontSize: 16, color: white, fontWeight: FontWeight.w500))),
//                  )
//                ],
//              ),
//            )
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget buildDatePickerField({
//     required TextEditingController controller,
//     required VoidCallback onTap,
//   }) {
//     return TextFormField(
//       readOnly: true,
//       controller: controller,
//       onTap: onTap,
//       decoration: InputDecoration(
//         hintText: "Select date",
//         suffixIcon: const Icon(Icons.calendar_today, color: black),
//         border: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(5),
//           borderSide: const BorderSide(color: backgroun2),
//         ),
//         contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
//       ),
//     );
//   }
// }
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;

import 'package:erestro/Helper/string.dart';
import 'package:erestro/Model/Offers/offer_model.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:mime/mime.dart';

import '../../Helper/Color.dart';
import '../../Helper/apiUtils.dart';
import '../../Helper/constant.dart';
import '../../Helper/session.dart';

import '../media.dart';

class AddUpdateOffers extends StatefulWidget {
  OffersModel offers;
  bool? isEdit;
  AddUpdateOffers({super.key, required this.offers, this.isEdit});

  @override
  State<AddUpdateOffers> createState() => _AddUpdateOffersState();
}

class _AddUpdateOffersState extends State<AddUpdateOffers> {
  String offerImageRelativePath = "";
  String offerImageUrl = "";
  String bannerImageRelativePath = "";
  String bannerImageUrl = "";
  List<String> typeList = ["Select Type", "Default", "Category", "Product"];
  TextEditingController offerTypeController =
      TextEditingController(text: "Select Type");

  bool _isDropdownOpen = false;

  DateTime? selectedStartDate;
  DateTime? selectedEndDate;
  bool _isNetworkAvail = true;

  TextEditingController startDateController = TextEditingController();
  TextEditingController endDateController = TextEditingController();

  String? offerImage;
  String? image;
  String? banner;
  String? bannerImage;

  String? img;
  String? SubDirectory;
  File? offerImageFile;
  File? bannerImageFile;
  String? offerImageName;
  String? bannerImageName;

  @override
  void initState() {
    print("njnm ${widget.isEdit}");
    offerImage = "";
    offerImageUrl = "";
    offerImageRelativePath = "";
    bannerImage = "";
    bannerImageUrl = "";
    bannerImageRelativePath = "";
    offerTypeController.text = widget.offers.type;
    startDateController.text = widget.offers.startDate;
    endDateController.text = widget.offers.endDate;
    image = widget.offers.image;
    banner = widget.offers.banner;
    print("cfgvhbjnkm $banner");
    getMedia();
    super.initState();
  }

  Future<void> pickImage({required bool isBanner}) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png', 'gif', 'bmp', 'eps'],
    );

    if (result != null) {
      File image = File(result.files.single.path!);
      String fileName = p.basename(image.path);

      print("Picked file name: $fileName");

      setState(() {
        if (isBanner) {
          bannerImageFile = image;
          bannerImageName = fileName;
          print("trfghyjuk  edwase $bannerImageName");
        } else {
          offerImageFile = image;
          offerImageName = fileName;
          print("trfghyjuk $offerImageName");
        }
      });
      print("trfghyjuk $bannerImageName");
    }
  }

  Future<void> getMedia() async {
    _isNetworkAvail = await isNetworkAvailable();
    if (_isNetworkAvail) {
      try {
        http.Response response = await http
            .post(getMediaApi, body: {}, headers: await ApiUtils.getHeaders())
            .timeout(
              Duration(
                seconds: timeOut,
              ),
            );
        var getdata = json.decode(response.body);
        bool error = getdata["error"];
        String? msg = getdata["message"];
        if (!error) {
          SubDirectory = getdata['data'][0]['sub_directory'];
          print("rftgbhnj $SubDirectory");
        } else {
          if (getdata[statusCode] == "120") {
            reLogin(context);
          }
          setsnackbar(msg!, context);
        }
      } on TimeoutException catch (_) {
        setsnackbar(getTranslated(context, "somethingMSg")!, context);
      }
    } else {}
  }

  Future<void> managePlans({required bool isEdit}) async {
    print("njnm ${widget.isEdit}");
    _isNetworkAvail = await isNetworkAvailable();
    if (_isNetworkAvail) {
      try {
        var request = http.MultipartRequest("POST", manageOffersApi);

        // Adding headers
        request.headers.addAll(await ApiUtils.getHeaders());

        // Adding parameters (fields)
        request.fields["offer_type"] = offerTypeController.text;
        request.fields["partner_id"] = CUR_USERID!;
        request.fields["start_date"] = startDateController.text;
        request.fields["end_date"] = endDateController.text;
        request.fields["category_id"] = widget.offers.id.toString();
        if (isEdit) {
          request.fields["edit_offer"] = widget.offers.id.toString();
        }

        print("bhnjmk,l. $offerImageRelativePath");

        // Use class variables instead of global variables
        if (offerImageRelativePath.isNotEmpty) {
          request.fields["image"] = offerImageRelativePath;
        } else {
          request.fields["image"] = widget.offers.relativePath!;
        }

        if (bannerImageRelativePath.isNotEmpty) {
          request.fields["banner"] = bannerImageRelativePath;
        } else {
          request.fields["banner"] = widget.offers.bannerRelativePath!;
        }
        print("📤 Sending Fields:");
        print("📤 Sending Fields:$bannerImageRelativePath");
        print("📤 Sending Fields:$banner");
        request.fields.forEach((key, value) {
          print("🔑 $key: $value");
        });
        // Sending the request
        var response = await request.send();

        // Reading the response
        var responseData = await response.stream.toBytes();
        var responseString = String.fromCharCodes(responseData);
        var getdata = json.decode(responseString);

        bool error = getdata["error"];
        String msg = getdata["message"];
        if (!error) {
          Navigator.pop(context, true);
          setsnackbar(msg, context);
        } else {
          if (getdata[statusCode] == "401") {
            reLogin(context);
          }
          setsnackbar(getTranslated(context, msg)!, context);
        }

        setState(() {});
      } on TimeoutException catch (_) {
        setsnackbar(getTranslated(context, "somethingMSg")!, context);
      }
    } else {
      setState(() {
        _isNetworkAvail = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Offers Management'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18.0),
        child: ListView(
          children: [
            const SizedBox(height: 16),

            Text(
              getTranslated(context, "type") ?? "Type",
              style: const TextStyle(
                fontSize: 16,
                color: black,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 10),

            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                color: white,
                border: Border.all(color: backgroun2, width: 1),
              ),
              margin: const EdgeInsetsDirectional.only(bottom: 10.0, end: 10.0),
              width: width,
              child: InkWell(
                onTap: () {
                  setState(() {
                    _isDropdownOpen = !_isDropdownOpen;
                  });
                  FocusScope.of(context).unfocus();
                },
                child: Stack(
                  children: [
                    TextFormField(
                      enabled: false,
                      controller: offerTypeController,
                      style: const TextStyle(color: black),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 12, horizontal: 10),
                        suffixIcon: Icon(
                          _isDropdownOpen
                              ? Icons.arrow_drop_up
                              : Icons.arrow_drop_down,
                          color: black,
                        ),
                      ),
                      validator: (val) => validateField(val, context),
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                    ),
                  ],
                ),
              ),
            ),

            if (_isDropdownOpen)
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  color: white,
                  border: Border.all(color: backgroun2, width: 1),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      spreadRadius: 1,
                      blurRadius: 3,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                width: width - 28,
                child: ListView.builder(
                  shrinkWrap: true,
                  physics: const ClampingScrollPhysics(),
                  itemCount: typeList.length,
                  itemBuilder: (context, index) {
                    return InkWell(
                      onTap: () {
                        setState(() {
                          offerTypeController.text = typeList[index];
                          _isDropdownOpen = false;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 12, horizontal: 16),
                        decoration: BoxDecoration(
                          border: index < typeList.length - 1
                              ? const Border(
                                  bottom:
                                      BorderSide(color: backgroun2, width: 0.5))
                              : null,
                        ),
                        child: Text(
                          typeList[index],
                          style: const TextStyle(color: black, fontSize: 14),
                        ),
                      ),
                    );
                  },
                ),
              ),

            const SizedBox(height: 16),

            Text(
              getTranslated(context, "start_date") ?? "Start Date",
              style: const TextStyle(
                  fontSize: 16, color: black, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 10),
            buildDatePickerField(
              controller: startDateController,
              onTap: () async {
                final pickedDate = await showDatePicker(
                  context: context,
                  initialDate: selectedStartDate ?? DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                );
                if (pickedDate != null) {
                  setState(() {
                    selectedStartDate = pickedDate;
                    startDateController.text =
                        DateFormat('dd/MM/yyyy').format(pickedDate);
                  });
                }
              },
            ),

            const SizedBox(height: 16),

            Text(
              getTranslated(context, "end_date") ?? "End Date",
              style: const TextStyle(
                  fontSize: 16, color: black, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 10),
            buildDatePickerField(
              controller: endDateController,
              onTap: () async {
                final pickedDate = await showDatePicker(
                  context: context,
                  initialDate: selectedEndDate ?? DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                );
                if (pickedDate != null) {
                  setState(() {
                    selectedEndDate = pickedDate;
                    endDateController.text =
                        DateFormat('dd/MM/yyyy').format(pickedDate);
                  });
                }
              },
            ),

            const SizedBox(height: 16),

            // Offer Image
            Text(
              getTranslated(context, "Offer Image *") ?? "Offer Image *",
              style: const TextStyle(
                  fontSize: 16, color: black, fontWeight: FontWeight.w500),
            ),
            SizedBox(height: 10),
            GestureDetector(
              onTap: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Media(
                      from: "offer",
                      banner: false,
                      type: widget.isEdit == true ? "edit" : "add",
                    ),
                  ),
                );

                if (result != null && mounted) {
                  setState(() {
                    offerImageRelativePath = result["relativePath"] ?? "";
                    offerImageUrl = result["url"] ?? "";
                  });
                  print("Retrieved offer image path: $offerImageRelativePath");
                }
              },
              // Rest of your widget

              child: Row(
                children: [
                  Container(
                    width: 150,
                    height: 40,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      color: primary,
                    ),
                    child: const Center(
                      child: Text(
                        "Upload Image",
                        style: TextStyle(
                            fontSize: 16,
                            color: white,
                            fontWeight: FontWeight.w500),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // if (offerImage != null) ...[
            //   const SizedBox(height: 10),
            //   Image.file(offerImage!, height: 200),
            // ],
            SizedBox(
              height: 10,
            ),

            ( offerImageUrl.isEmpty) && (widget.offers.image == null || widget.offers.image.isEmpty)
                ? SizedBox()
                : Container(
              height: 200,
              width: 200,
              decoration: BoxDecoration(

                image: DecorationImage(
                  image: NetworkImage(
                      (offerImageUrl != null && offerImageUrl.isNotEmpty)
                          ?offerImageUrl
                          : widget.offers.image
                  ),
                  fit: BoxFit.contain,
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Banner Image
            Text(
              getTranslated(context, "bannerimage*") ?? "Banner Image *",
              style: const TextStyle(
                  fontSize: 16, color: black, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Media(
                      from: "offer",
                      banner: true,
                      type: widget.isEdit == true ? "edit" : "add",
                    ),
                  ),
                );

                if (result != null && mounted) {
                  setState(() {
                    bannerImageRelativePath = result["relativePath"] ?? "";
                    bannerImageUrl = result["url"] ?? "";
                  });
                  print("Retrieved banner image path: $bannerImageUrl");
                }
              },
              child: Row(
                children: [
                  Container(
                    height: 40,
                    width: 150,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      color: primary,
                    ),
                    child: const Center(
                      child: Text(
                        "Upload Image",
                        style: TextStyle(
                            fontSize: 16,
                            color: white,
                            fontWeight: FontWeight.w500),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 10,
            ),
            ( bannerImageRelativePath.isEmpty) && (widget.offers.bannerImage == null || widget.offers.bannerImage!.isEmpty)
                ? SizedBox()
                : Container(
              height: 200,
              width: 200,
              decoration: BoxDecoration(

                image: DecorationImage(
                  image: NetworkImage(
                      (bannerImageUrl != null && bannerImageUrl.isNotEmpty)
                          ? bannerImageUrl
                          : widget.offers.bannerImage!
                  ),
                  fit: BoxFit.contain,
                ),
              ),
            ),

            SizedBox(height: 30),
            InkWell(
              onTap: () {
                managePlans(isEdit: widget.isEdit!);
              },
              child: Container(
                height: 40,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  color: primary,
                ),
                child: const Center(
                  child: Text(
                    "Update Offer",
                    style: TextStyle(
                        fontSize: 16,
                        color: white,
                        fontWeight: FontWeight.w500),
                  ),
                ),
              ),
            ),
            SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Widget buildDatePickerField({
    required TextEditingController controller,
    required VoidCallback onTap,
  }) {
    return TextFormField(
      readOnly: true,
      controller: controller,
      onTap: onTap,
      decoration: InputDecoration(
        hintText: "Select date",
        suffixIcon: const Icon(Icons.calendar_today, color: primary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(5),
          borderSide: const BorderSide(color: backgroun2),
        ),
        contentPadding:
            const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
      ),
    );
  }
}
