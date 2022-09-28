class SearchModel {
  int id;
  int stateId;
  String name;
  int cost;

  SearchModel({this.id, this.stateId, this.name, this.cost});

  SearchModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    stateId = json['state_id'];
    name = json['name'];
    cost = json['cost'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['state_id'] = this.stateId;
    data['name'] = this.name;
    data['cost'] = this.cost;
    return data;
  }
}
