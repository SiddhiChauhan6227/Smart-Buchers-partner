

class Plans {
  String? id;
  String? name;
  String? price;
  String? duration;
  String? offerLimit;
  String? description;
  String? allowOffers;
  String? status;
  String? dateCreated;

  Plans(
      {this.id,
        this.name,
        this.price,
        this.duration,
        this.offerLimit,
        this.description,
        this.allowOffers,
        this.status,
        this.dateCreated});

  Plans.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    price = json['price'];
    duration = json['duration'];
    offerLimit = json['offer_limit'];
    description = json['description'];
    allowOffers = json['allow_offers'];
    status = json['status'];
    dateCreated = json['date_created'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['price'] = this.price;
    data['duration'] = this.duration;
    data['offer_limit'] = this.offerLimit;
    data['description'] = this.description;
    data['allow_offers'] = this.allowOffers;
    data['status'] = this.status;
    data['date_created'] = this.dateCreated;
    return data;
  }
}
