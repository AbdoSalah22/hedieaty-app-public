import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:googleapis_auth/auth_io.dart' as auth;
import 'package:http/http.dart' as http;
import 'package:googleapis/servicecontrol/v1.dart' as servicecontrol;

Future<String> getAccessToken() async {
  // Your client ID and client secret obtained from Google Cloud Console
  final serviceAccountJson = {
    "type": "service_account",
    "project_id": dotenv.env['project_id'],
    "private_key_id": dotenv.env['private_key_id'],
    "private_key": dotenv.env['private_key'],
    "client_email": dotenv.env['client_email'],
    "client_id": dotenv.env['client_id'],
    "auth_uri": "https://accounts.google.com/o/oauth2/auth",
    "token_uri": "https://oauth2.googleapis.com/token",
    "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
    "client_x509_cert_url": dotenv.env['client_x509_cert_url'],
    "universe_domain": "googleapis.com"
  };

  List<String> scopes = [
    "https://www.googleapis.com/auth/userinfo.email",
    "https://www.googleapis.com/auth/firebase.database",
    "https://www.googleapis.com/auth/firebase.messaging"
  ];

  http.Client client = await auth.clientViaServiceAccount(
    auth.ServiceAccountCredentials.fromJson(serviceAccountJson),
    scopes,
  );

  // Obtain the access token
  auth.AccessCredentials credentials = await auth.obtainAccessCredentialsViaServiceAccount(
      auth.ServiceAccountCredentials.fromJson(serviceAccountJson),
      scopes,
      client
  );

  // Close the HTTP client
  client.close();

  // Return the access token
  return credentials.accessToken.data;
}