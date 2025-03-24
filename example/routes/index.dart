import 'package:dart_frog/dart_frog.dart';
import '../lib/models/user.dart';
Future<Response> onRequest(RequestContext context) async {
  final request = context.request;
  //     [Request properties]
  // connection info
  final conn = request.connectionInfo;
  // headers
  final headers = request.headers; // Map <String, String>
  // method
  final method = request.method; // HttpMethod enum

  final params = request.uri.queryParameters;
  //  [Request  methods]
  final body = await request.body(); // Future<String>!!!
  final json_body = await request.json();

  final name = context.read<String>();


  return Response.json(body: {
    'conn_info': conn?.remotePort,
    'host_info': headers['host'],
    'original_method': method.toString(),
    'user_id': params['user_id'],
    'body': body,
    'body_json': json_body['greetings'],
    'body_json_name': "${json_body['greetings']}, $name",
    'user_info': User(name: 'Dash', age: 42),
  });
}
