import 'package:dart_frog/dart_frog.dart';
import 'dart:io';

Handler authMiddleware(Handler handler) {
  return (context) async {
    final request = context.request;

    // Check if the 'Authorization' header is present
    if (!request.headers.containsKey('Authorization')) {
      return Response.json(
        body: {'error': 'Authorization header is missing'},
        statusCode: HttpStatus.unauthorized,
      );
    }

    // Continue processing the request
    return await handler(context);
  };
}