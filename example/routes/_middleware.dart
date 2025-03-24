import 'package:dart_frog/dart_frog.dart';
import 'package:example/middleware/authmiddleware.dart';

Handler middleware(Handler handler) {
  return handler
  .use(authMiddleware)
  .use(requestLogger())
  .use(provider<String>((context) => 
  'Liza')); //e.g. DB entry could be passed?
}