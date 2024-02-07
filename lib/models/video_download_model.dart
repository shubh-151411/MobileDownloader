class VideoDownload {
  String? url;
  String? title;
  String? thumbnail;
  String? duration;
  String? source;
  List<Medias>? medias;
  

  VideoDownload(
      {this.url,
      this.title,
      this.thumbnail,
      this.duration,
      this.source,
      this.medias,
      });

  VideoDownload.fromJson(Map<String, dynamic> json) {
    url = json['url'];
    title = json['title'];
    thumbnail = json['thumbnail'];
    duration = json['duration'];
    source = json['source'];
    if (json['medias'] != null) {
      medias = <Medias>[];
      json['medias'].forEach((v) {
        medias!.add(new Medias.fromJson(v));
      });
    }
    
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['url'] = this.url;
    data['title'] = this.title;
    data['thumbnail'] = this.thumbnail;
    data['duration'] = this.duration;
    data['source'] = this.source;
    if (this.medias != null) {
      data['medias'] = this.medias!.map((v) => v.toJson()).toList();
    }
    
    return data;
  }
}

class Medias {
  String? url;
  String? quality;
  String? format;
  var size;
  String? formattedSize;
  bool? videoAvailable;
  bool? audioAvailable;
  bool? chunked;
  bool? cached;

  Medias(
      {this.url,
      this.quality,
      this.format,
      this.size,
      this.formattedSize,
      this.videoAvailable,
      this.audioAvailable,
      this.chunked,
      this.cached});

  Medias.fromJson(Map<String, dynamic> json) {
    url = json['url'];
    quality = json['quality'];
    format = json['extension'];
    size = json['size'];
    formattedSize = json['formattedSize'];
    videoAvailable = json['videoAvailable'];
    audioAvailable = json['audioAvailable'];
    chunked = json['chunked'];
    cached = json['cached'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data =  Map<String, dynamic>();
    data['url'] = this.url;
    data['quality'] = this.quality;
    data['extension'] = this.format;
    data['size'] = this.size;
    data['formattedSize'] = this.formattedSize;
    data['videoAvailable'] = this.videoAvailable;
    data['audioAvailable'] = this.audioAvailable;
    data['chunked'] = this.chunked;
    data['cached'] = this.cached;
    return data;
  }
}
