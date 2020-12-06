import 'package:event_bus/event_bus.dart';
import 'HttpErrorEvent.dart';

class Code{
  static const NETWORK_ERROR = -1;
  static const NETWORK_TIMEOUT = -2;
  static const NETWORK_JSON_EXCEPTION = -3;
  static const SUCCESS = 0;
  static final EventBus eventBus = new EventBus();

  static errorHandleFunction(code, message) {
    // eventBus.fire(new HttpErrorEvent(code,message));
    return code;
  }
}