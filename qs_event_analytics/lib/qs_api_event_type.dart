enum QsApiEventType {
  appIn,
  appOut,
  pageIn,
  pageOut,
  click,
  valueChange,
  load,
  show,
  close,
  state,
  error;

  String get typeCode {
    switch (this) {
      case QsApiEventType.appIn:
        return "in";
      case QsApiEventType.appOut:
        return "out";
      case QsApiEventType.pageIn:
        return "in";
      case QsApiEventType.pageOut:
        return "out";
      case QsApiEventType.click:
        return "click";
      case QsApiEventType.valueChange:
        return "click";
      case QsApiEventType.load:
        return "load";
      case QsApiEventType.show:
        return "in";
      case QsApiEventType.close:
        return "out";
      case QsApiEventType.state:
        return "load";
      case QsApiEventType.error:
        return "error";
    }
  }

  String get eventNamePrefix {
    switch (this) {
      case QsApiEventType.appIn:
        return "@name";
      case QsApiEventType.appOut:
        return "@name";
      case QsApiEventType.pageIn:
        return "进入-【@name】";
      case QsApiEventType.pageOut:
        return "离开-【@name】";
      case QsApiEventType.valueChange:
        return "值改变-@name";
      case QsApiEventType.click:
        return "点击-@name";
      case QsApiEventType.load:
        return "加载-@name";
      case QsApiEventType.show:
        return "显示-【@name】";
      case QsApiEventType.close:
        return "关闭-【@name】";
      case QsApiEventType.state:
        return "状态-@name";
      case QsApiEventType.error:
        return "错误-@name";
    }
  }
}
