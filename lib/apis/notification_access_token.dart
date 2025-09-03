import 'dart:developer';
import 'package:googleapis_auth/auth_io.dart';

class NotificationAccessToken {
  static String? _token;

  static Future<String?> get getToken async => _token ?? await _getAccessToken();

  static Future<String?> _getAccessToken() async {
    try {
      const fMessagingScope =
          'https://www.googleapis.com/auth/firebase.messaging';

      final client = await clientViaServiceAccount(
        ServiceAccountCredentials.fromJson({
          "type": "service_account",
          "project_id": "pingme-409d8",
          "private_key_id": "b5f9273f3fbf10ad35b0e2de4cd41b71225598bc",
          "private_key": "-----BEGIN PRIVATE KEY-----\nMIIEvgIBADANBgkqhkiG9w0BAQEFAASCBKgwggSkAgEAAoIBAQCm9Azq0qqPVpa8\n51w0l1PgnR/Uy8nvEV2kHQVeIfGdjiSarePOzlVHuWtG+0gYhyGbtjaX/xXYqc8n\nQVRFpzz6xyDfWQTSn21blspMjW64pdpxXUvC12Px9SgVk4FloGFswkgR9m0Rq4jG\nF/PJhvvo4D6zftuDVvY6pZnzKfA8WLwcBSe4YMknIG6zO1XTNgppxJ/4iPiOug7m\nOHRCGwA1ryrXheZ4R8MAm8VtcG/8xFKLR65m/iyTXjXYI+JkCZsSuqTRv53zm31e\nt/tkO4xDxy06X2XcBkZdN1mEgUMbo52tM4Ya5kZxPUBJ5nq6AjtSd4h63yUhY01/\nxGJcUxDtAgMBAAECggEABWPz1tEeeKpPC6Jcs8X/C02HbZN23aUt5NKbDcMCzhd8\nzxG2PUMkNcCi2hPa7A/Q4fosIRQ3XFt/OME/O1B/A4nSYeO56CMFoONpfLdET+nq\n96YPgCb8Lx+/P5MXpnRbMOvE7++I7f0f2WWElYkqMQasf5ck90Sjhpk6M0OzYf9e\nETQhtrqhuie9Lx3IFOiGCB6NzjlKWJRvlD40OjRof3se0j8LfQNEa9Ur7VRVqMOO\nK6e77iN/geEXlHdPMF5zSKsIze2UG81qc5vvzkvpYYqMiNrMmu2mNjS6dVyVyGG4\nN0SRLKtbIhbi4d5z0ssDO09sYqiKvwZ1/yX1KdsecQKBgQDd+69UcXwWKL6rQrmM\nhIL9hqpwxunMpWqUyEboidBL7y04+eQ8VYxk+f8LJK5pHI3Sp3rx8bfc0miRKK3K\njNdQjY9hCtI3U8l/OnBOHRJQVjHqqc4sHLGtLaaISkcL6E8vbUzDTdLyliQHgLXG\nbxwaBkbNtI6gVzPxguEN4LKTEwKBgQDAiZD+9/h8NtMVXMp5Ihq9ccqWLWAxAiNr\nhFJGd9oa4eVbMpPnlorM9IOXn1mespOLHaQi0zoDnBuyh+nLaxTQMSsWK8fkR49r\n3sns4wV2TtyhfM6CIM/c9CuYWsQ9X+lozpENLVBTrlUcoGDkiPupfEMn5DTDwNgg\nwOLO8LRL/wKBgFYKSckXO5tzK4RCFp1Kd2NBISsZTmHN8+O7RRC46g2kpQiigz6H\ngiVZaOuuyhNfx/DQjazdngBvZaxt8f7CXGqSk/JvOU/MoBs6UXFVf1W4MxzbuFgM\nvyl6ukO1Vphc8ORXHxvMPGlenJRz5QEG7AOCT0tIIsgvRKjlq8mvQEgVAoGBALyQ\nvnIH99PnedntM9to/FlXrbphHFlDJ99wC4g6b2BupssngNWKicvrGUoQ5ZvYd0oD\nMLJuvt20MSgrll0ENbEkxncDT9USBLP30TlwqfPRjqGV80Zczlcux9eB5bnaSmW8\nETGflJEwJulPZTXNtvOp4Leb99VT9Bg38KoN8faPAoGBANCWArE+tjv5uGOJViAF\nwS2yHpYRIA+Gszc3n1n8zLYeoT6sY0KiJ77zUG8YpHF1vdUMCOS9uy8FsLJe1Kz/\nzzCxuf/3/PQBfsdGrtCX08hLoGXWvdel0GirJmBoGwH5hxaFkonRhjvthUlSINPe\nrci0sfI8g6gcFb7pBuU6ALJF\n-----END PRIVATE KEY-----\n",
          "client_email": "firebase-adminsdk-fbsvc@pingme-409d8.iam.gserviceaccount.com",
          "client_id": "110652732163383390469",
          "auth_uri": "https://accounts.google.com/o/oauth2/auth",
          "token_uri": "https://oauth2.googleapis.com/token",
          "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
          "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/firebase-adminsdk-fbsvc%40pingme-409d8.iam.gserviceaccount.com",
          "universe_domain": "googleapis.com"
        }),
        [fMessagingScope],
      );

      _token = client.credentials.accessToken.data;

      return _token;
    } catch (e) {
      log('$e');
      return null;
    }
  }
}