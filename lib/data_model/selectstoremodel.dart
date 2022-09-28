class SelectStoreModel {
  SelectStoreModel({
    this.id,
    this.name,
    this.logo,
  });

  int id;
  String name;
  String logo;

  factory SelectStoreModel.fromJson(Map<String, dynamic> json) =>
      SelectStoreModel(
        id: json["id"],
        name: json["name"],
        logo: json["logo"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "logo": logo,
      };
}
