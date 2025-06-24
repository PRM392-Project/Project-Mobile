import 'package:signalr_netcore/signalr_client.dart';

class SignalRService {
  static HubConnection? _connection;
  static bool isConnected = false;

  /// ✅ Bắt đầu kết nối đến SignalR hub
  static Future<void> startConnection(
      String accessToken,
      Function(Map<String, dynamic>) onReceiveMessage,
      ) async {
    if (_connection != null && _connection!.state == HubConnectionState.Connected) {
      print("⚠️ SignalR đã kết nối.");
      return;
    }

    const serverUrl =
        'https://snaproom-e7asc0ercvbxazb8.southeastasia-01.azurewebsites.net/chathub';

    final httpOptions = HttpConnectionOptions(
      accessTokenFactory: () async => accessToken,
      skipNegotiation: true,
      transport: HttpTransportType.WebSockets,
    );

    print("🛠️ Khởi tạo HubConnection...");
    _connection = HubConnectionBuilder()
        .withUrl(serverUrl, options: httpOptions)
        .withAutomaticReconnect()
        .build();

    _connection!.on("ReceiveMessage", (args) {
      print("📥 Nhận được tin nhắn: $args");
      try {
        final data = args?.first;
        if (data is Map<String, dynamic>) {
          onReceiveMessage(data);
        } else {
          print("⚠️ Dữ liệu không đúng định dạng Map<String, dynamic>: $data");
        }
      } catch (e) {
        print("❌ Lỗi xử lý ReceiveMessage: $e");
      }
    });

    _connection!.onclose(({error}) {
      isConnected = false;
      print("🛑 Mất kết nối: ${error?.toString() ?? 'Không rõ'}");
    });

    _connection!.onreconnecting(({error}) {
      print("🔄 Đang reconnect... ${error?.toString() ?? 'Không rõ'}");
    });

    _connection!.onreconnected(({connectionId}) {
      isConnected = true;
      print("🔁 Reconnected: $connectionId");
    });

    try {
      print("🚀 Đang kết nối...");
      await _connection!.start();
      isConnected = true;
      print("✅ Đã kết nối SignalR.");
    } catch (err) {
      isConnected = false;
      print("❌ Lỗi kết nối SignalR: $err");
    }
  }

  /// ✅ Gửi tin nhắn
  static Future<void> sendMessage(
      String senderId,
      String receiverId,
      String content,
      ) async {
    if (_connection == null || _connection!.state != HubConnectionState.Connected) {
      print("⚠️ Không thể gửi tin nhắn: chưa kết nối.");
      return;
    }

    try {
      await _connection!.invoke("SendMessage", args: [senderId, receiverId, content]);
      print("✅ Tin nhắn đã gửi.");
    } catch (err) {
      print("❌ Lỗi gửi tin nhắn: $err");
    }
  }

  /// ✅ Tham gia vào group của 1 cuộc trò chuyện
  static Future<void> joinConversation(String conversationId) async {
    if (_connection == null || _connection!.state != HubConnectionState.Connected) {
      print("⚠️ Không thể join group: chưa kết nối.");
      return;
    }

    try {
      await _connection!.invoke("JoinConversation", args: [conversationId]);
      print("🔗 Đã join conversation group: $conversationId");
    } catch (err) {
      print("❌ Lỗi khi join conversation: $err");
    }
  }

  /// ✅ Ngắt kết nối
  static Future<void> stopConnection() async {
    if (_connection != null) {
      try {
        print("🔌 Đang ngắt kết nối...");
        await _connection!.stop();
        isConnected = false;
        print("✅ Đã ngắt kết nối.");
      } catch (err) {
        print("❌ Lỗi khi ngắt kết nối: $err");
      }
    } else {
      print("ℹ️ Không có kết nối để ngắt.");
    }
  }

  /// ✅ Truy cập kết nối hiện tại (nếu cần)
  static HubConnection? get connection => _connection;
}
