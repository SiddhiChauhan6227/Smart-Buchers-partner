import 'dart:async';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../Helper/Color.dart';
import '../../Helper/session.dart';
import '../../Helper/string.dart';
import '../../Model/Offers/offer_model.dart';
import '../home.dart';
import 'create_edit_offers.dart';

class OffersScreen extends StatefulWidget {
  @override
  State<OffersScreen> createState() => _OffersScreenState();
}

class _OffersScreenState extends State<OffersScreen> {

  bool _isNetworkAvail = true;
  String? jwtToken;
  List<OffersModel> offersList = [];
  bool isLoading = false; // declare this in your state

  // Sample product data


  @override
  void initState() {
    getOffers();
    super.initState();
  }
 Future<void> getOffers() async {
   _isNetworkAvail = await isNetworkAvailable();
   if (_isNetworkAvail) {
     try {
       setState(() {
         isLoading = true; // start loading
       });

       jwtToken = await getPrefrence(token);
       var parameter = {'partner_id': CUR_USERID};

       apiBaseHelper.postAPICall(getOffersApi, parameter, context).then((getdata) async {
         bool error = getdata["error"];
         String msg = getdata["message"];

         if (!error) {
           var data = getdata["data"];
           offersList = (data as List).map((data) => OffersModel.fromJson(data)).toList();
         } else {
           setsnackbar(msg, context);
         }

         setState(() {
           isLoading = false; // end loading
         });
       });
     } on TimeoutException catch (_) {
       setState(() {
         isLoading = false;
       });
       setsnackbar(getTranslated(context, "somethingMSg")!, context);
     }
   } else {
     setState(() {
       _isNetworkAvail = false;
       isLoading = false;
     });
   }
 }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: InkWell(

            onTap:(){
              Navigator.pop(context);
            },child: Icon(Icons.arrow_back_ios)),
        actions: [

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: InkWell(
              onTap: ()async{
                OffersModel offers=OffersModel(id: "", type: "Select Type", typeId: "", image: "", banner: "",
                    startDate: "", endDate: "", partnerId: "", status: "", dateAdded: "",
                    bannerImage: "", data: [], relativePath: '', bannerRelativePath: '');
                final result = await  Navigator.push(
                  context,
                  CupertinoPageRoute(
                    builder: (BuildContext context) => AddUpdateOffers( offers: offers,isEdit:false),
                  ),
                );
                print("tgyhuijmk,sw  $result");
                if (result == true) {
                  print("tgyhuijmk, $result");
                  getOffers(); // <-- Your method to refresh the offer list
                }
              },
              child: CircleAvatar(
                  radius: 15,
                  backgroundColor: primary,
                  child: Icon(
                    Icons.add,
                    color: Colors.white,
                  )),
            ),
          )
        ],
        title: Text('Offers Management'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body:isLoading
          ? const Center(child: CircularProgressIndicator())
          : offersList.isEmpty ? Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(

                          height: 200,
                         width: 500,
                         decoration: BoxDecoration(image: DecorationImage(image: AssetImage("assets/images/gif/nodata.png"))),
                        ),
              SizedBox(height: 30,),
              Text(
                "NO OFFERS !!",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ):ListView.builder(
        padding: EdgeInsets.only(left: 16, right: 16, top: 10),
        itemCount: offersList.length,
        itemBuilder: (context, index) {
          final product = offersList[index];
          return Padding(
            padding: EdgeInsets.only(bottom: 10),
            child: InkWell(
              onTap: ()async{
                final result = await Navigator.push(
                  context,
                  CupertinoPageRoute(
                    builder: (BuildContext context) => AddUpdateOffers( offers: product,isEdit:true),
                  ),
                );
                if (result == true) {
                  getOffers(); // <-- Your method to refresh the offer list
                }
              },
              child: ProductCard(
                offerId: product.id,
                imageUrl: product.image,
                title: product.type,
                bannerImage:product.banner,
                created: product.startDate,
                updated: product.endDate,

              ),
            ),
          );
        },
      ),
    );
  }
}

class ProductCard extends StatefulWidget {
  final String offerId;
  final String imageUrl;
  final String bannerImage;
  final String title;
  final String created;
  final String updated;


  const ProductCard({
    Key? key,
    required this.offerId,
    required this.imageUrl,
    required this.title,
    required this.bannerImage,
    required this.created,
    required this.updated,

  }) : super(key: key);

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {

  deleteOffers(id) async{
    var parameter = {'offer_id':id};

    apiBaseHelper
        .postAPICall(deleteOffersApi  , parameter, context)
        .then((getdata) async {
      bool error = getdata["error"];
      String msg = getdata["message"];


        setsnackbar(msg, context);

      setState(
            () {},
      );
    });

  }
  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      Positioned(
        top: 0,
        left: 0,
        right: 0,
        bottom: 0,
        child: Container(
          width: double.infinity,
          height: 120,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: widget.bannerImage.isEmpty
                  ? Border.all(color: Colors.grey, width: 1) // 👈 border if empty
                  : null,
              image: DecorationImage(
                  image: NetworkImage(
                    widget.bannerImage,
                  ),
                  fit: BoxFit.cover)),
        ),
      ),
      ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
            child: Container(
              // width: 320,
              // height: 340,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Colors.white.withOpacity(0.08),
                border: Border.all(color: Colors.white.withOpacity(0.2)),
              ),
              padding: const EdgeInsets.all(10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Product Image
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      widget.imageUrl,
                      width: 90,
                      height: 90,
                      fit: BoxFit.cover,
                    ),
                  ),
                  SizedBox(width: 16),
                  // Product Details
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  widget.title,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                InkWell(
                                    onTap: (){
                                      deleteOffers(widget.offerId);
                                    },
                                    child: Icon(Icons.delete,color: primary,size: 20,))
                              ],
                            ),
                            SizedBox(height: 4),
                            Text(
                              "🗓️ Start Date : ${widget.created}",
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.black,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: 8),
                            SizedBox(height: 4),
                            Text(
                              "🗓️ End Date : ${widget.updated}",
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.black,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )),
    ]);
  }
}
