class FocusListSettings{
  String id='';
  String uid='';
  List<String> tags=[];
  bool includeOldest=false;

  FocusListSettings({required this.uid});

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'tags':tags,
      'includeOldest':includeOldest,
    };
  }

  static FocusListSettings fromMap(String id,Map<String, dynamic> map) {
   FocusListSettings settings = FocusListSettings(uid: map['uid']);
    settings.id=id;
    if(map['tags']!=null) {
      settings.tags = map['tags'].cast<String>();
    }
    return settings;
  }
}