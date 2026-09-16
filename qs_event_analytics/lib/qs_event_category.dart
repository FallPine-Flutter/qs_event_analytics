enum QsEventCategory {
  all,
  firebase,
  api;

  bool get shouldRecordFirebase {
    return this == QsEventCategory.all || this == QsEventCategory.firebase;
  }

  bool get shouldRecordApi {
    return this == QsEventCategory.all || this == QsEventCategory.api;
  }
}
