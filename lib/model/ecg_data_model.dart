class EcgDataModel {
    bool bLeadoff;
    Ecgdata ecgdata;
    int nHR;

    EcgDataModel({this.bLeadoff, this.ecgdata, this.nHR});

    factory EcgDataModel.fromJson(Map<String, dynamic> json) {
        return EcgDataModel(
            bLeadoff: json['bLeadoff'],
            ecgdata: json['ecgdata'] != null ? Ecgdata.fromJson(json['ecgdata']) : null,
            nHR: json['nHR'],
        );
    }

    Map<String, dynamic> toJson() {
        final Map<String, dynamic> data = new Map<String, dynamic>();
        data['bLeadoff'] = this.bLeadoff;
        data['nHR'] = this.nHR;
        if (this.ecgdata != null) {
            data['ecgdata'] = this.ecgdata.toJson();
        }
        return data;
    }
}

class Ecgdata {
    List<Data> data;
    int frameNum;

    Ecgdata({this.data, this.frameNum});

    factory Ecgdata.fromJson(Map<String, dynamic> json) {
        return Ecgdata(
            data: json['data'] != null ? (json['data'] as List).map((i) => Data.fromJson(i)).toList() : null,
            frameNum: json['frameNum'],
        );
    }

    Map<String, dynamic> toJson() {
        final Map<String, dynamic> data = new Map<String, dynamic>();
        data['frameNum'] = this.frameNum;
        if (this.data != null) {
            data['`data`'] = this.data.map((v) => v.toJson()).toList();
        }
        return data;
    }
}

class Data {
    int data;
    int flag;

    Data({this.data, this.flag});

    factory Data.fromJson(Map<String, dynamic> json) {
        return Data(
            data: json['data'],
            flag: json['flag'],
        );
    }

    Map<String, dynamic> toJson() {
        final Map<String, dynamic> data = new Map<String, dynamic>();
        data['data'] = this.data;
        data['flag'] = this.flag;
        return data;
    }
}