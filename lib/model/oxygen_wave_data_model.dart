import 'dart:convert';

class OxgenWaveDataModel {
    List<WaveData>? waveData;

    OxgenWaveDataModel({this.waveData});

    factory OxgenWaveDataModel.fromJson(Map<String, dynamic> json) {
        return OxgenWaveDataModel(
            waveData: json['waveData'] != null ? (json['waveData'] as List).map((i) => WaveData.fromJson(i)).toList() : null,
        );
    }

    Map<String, dynamic> toJson() {
        final Map<String, dynamic> data = new Map<String, dynamic>();
        if (this.waveData != null) {
            data['waveData'] = this.waveData?.map((v) => v.toJson()).toList();
        }
        return data;
    }

    @override
  String toString() {
    return jsonEncode(this);
  }
}

class WaveData {
    int? data;
    int? flag;

    WaveData({this.data, this.flag});

    factory WaveData.fromJson(Map<String, dynamic> json) {
        return WaveData(
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