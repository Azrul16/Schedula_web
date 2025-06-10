import 'package:get/get.dart';
import 'package:schedula/chatAI/auth_controller.dart';

class InitializeController {
  void init() {
    Get.lazyPut(() => AuthController());
  }
}
