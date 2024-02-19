import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:sendbird_sdk/sendbird_sdk.dart';
import 'package:dash_chat_2/dash_chat_2.dart';

class DashChatScreen extends StatefulWidget {
  final String appId;
  final String userId;
  final List<String> otherUserIds;

  DashChatScreen(
      {required this.appId, required this.userId, required this.otherUserIds});

  @override
  DashChatScreenState createState() => DashChatScreenState();
}

class DashChatScreenState extends State<DashChatScreen>
    with ChannelEventHandler {
  GroupChannel? _channel;
  List<BaseMessage> _messages = [];
  String? _message = '';
  late bool isCurrentUser;
  final TextEditingController _textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadSendbird(
      widget.appId,
      widget.userId,
      widget.otherUserIds,
    );
    SendbirdSdk().addChannelEventHandler("sendbird_chat", this);
  }

  @override
  void dispose() {
    super.dispose();
    SendbirdSdk().removeChannelEventHandler("sendbird_chat");
  }

  @override
  void onMessageReceived(BaseChannel channel, BaseMessage message) {
    super.onMessageReceived(channel, message);
    setState(() {
      _messages.add(message);
      _message = '';
    });
    _textController.clear();
    _message = '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _channel == null
          ? const Text("Loading...")
          : Container(
              color: const Color(0xff0E0D0D),
              child: DashChat(
                messages: asDashChatMessages(_messages),
                currentUser: asDashChatUser(SendbirdSdk().currentUser!),
                onSend: (newMessage) {},
                messageOptions: MessageOptions(
                    currentUserTextColor: Colors.white,
                    currentUserContainerColor: Colors.amber,
                    showOtherUsersAvatar: true,
                    showOtherUsersName: true,
                    showTime: false,
                    showCurrentUserAvatar: false,
                    messageDecorationBuilder: (message, previousMessage,
                            nextMessage) =>
                        BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: isCurrentUser
                                  ? [
                                      const Color(0xffFF006B),
                                      const Color(0xffFF4593)
                                    ]
                                  : [
                                      const Color(0xff1A1A1A),
                                      const Color(0xff1A1A1A)
                                    ],
                            ),
                            borderRadius: BorderRadius.only(
                                topLeft: isCurrentUser
                                    ? const Radius.circular(18.0)
                                    : const Radius.circular(4.0),
                                bottomLeft: isCurrentUser
                                    ? const Radius.circular(18.0)
                                    : const Radius.circular(16.0),
                                topRight: isCurrentUser
                                    ? const Radius.circular(4.0)
                                    : const Radius.circular(18.0),
                                bottomRight: isCurrentUser
                                    ? const Radius.circular(16.0)
                                    : const Radius.circular(18.0))),
                    textColor: Colors.white,
                    borderRadius: 10.0),
                inputOptions: InputOptions(
                  onTextChange: (value) {
                    setState(() {
                      _message = value;
                    });
                  },
                  textController: _textController,
                  alwaysShowSend: false,
                  sendButtonBuilder: (builder) => Container(),
                  showTraillingBeforeSend: false,
                  leading: [
                    SizedBox(
                      height: 40,
                      width: 40,
                      child: IconButton(
                        icon: const Icon(
                          Icons.add,
                          color: Color(0xfff5f5f5),
                          size: 24.0,
                        ),
                        onPressed: () {},
                      ),
                    )
                  ],
                  inputDecoration: InputDecoration(
                      hintText: '안녕하세요...',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20.0),
                          borderSide: const BorderSide(color: Colors.white)),
                      filled: true,
                      fillColor: const Color(0xfF323232),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20.0, vertical: 0.0),
                      suffixIcon: IconButton(
                          onPressed: () {
                            _textController.clear();
                            _message = '';

                            final sentMessage =
                                _channel?.sendUserMessageWithText(_message!);
                            setState(() {
                              _messages.add(sentMessage!);
                              _message = '';
                            });
                          },
                          icon: Image.asset('assets/chat_send.png',
                              width: 24, height: 24))),
                ),
              ),
            ),
    );
  }

  ChatUser asDashChatUser(User user) {
    if (user == null) {
      return ChatUser(
        id: "",
        firstName: "",
        profileImage: "",
      );
    }

    if (user != null) {
      setState(() {
        isCurrentUser = user.isCurrentUser;
      });
    }

    return ChatUser(
      id: user.userId,
      firstName: user.nickname != null ? user.nickname : "",
      profileImage: user.profileUrl != null ? user.profileUrl : "",
    );
  }

  List<ChatMessage> asDashChatMessages(List<BaseMessage> messages) {
    return [
      for (BaseMessage sbm in messages.reversed)
        ChatMessage(
          createdAt: DateTime.now(),
          text: sbm.message,
          user: asDashChatUser(sbm.sender!),
        )
    ];
  }

  void loadSendbird(
    String appId,
    String userId,
    List<String> otherUserIds,
  ) async {
    try {
      await connectWithSendbird(appId, userId);

      final channel = await GroupChannel.getChannel(
          'https://api-BC823AD1-FBEA-4F08-8F41-CF0D9D280FBF.sendbird.com/sendbird_open_channel_14092_bf4075fbb8f12dc0df3ccc5c653f027186ac9211');

      final messages = await channel.getMessagesByTimestamp(
        DateTime.now().millisecondsSinceEpoch * 1000,
        MessageListParams(),
      );

      setState(() {
        _channel = channel;
        _messages = messages;
      });
    } catch (e) {
      print(e);
    }
  }

  Future<User> connectWithSendbird(
    String appId,
    String userId,
  ) async {
    try {
      final sendbird = SendbirdSdk(appId: appId);
      final user = await sendbird.connect(userId);
      return user;
    } catch (e) {
      throw e;
    }
  }
}
