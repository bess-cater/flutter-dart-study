import 'package:dart_frog/dart_frog.dart';

// accessible at /users/2 users/345 etc!!!!
Response onRequest(RequestContext context, String id) {
  return Response(body: 'post id: $id');
}