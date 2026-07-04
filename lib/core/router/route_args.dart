class VitalHistoryArgs {
  final String configId;
  final String configName;
  const VitalHistoryArgs({required this.configId, required this.configName});
}

class ThreadArgs {
  final String conversationId;
  final String contactName;
  const ThreadArgs({required this.conversationId, required this.contactName});
}

class ChatArgs {
  final String connectionId;
  final String professionalName;
  final String professionalSpecialty;
  const ChatArgs({
    required this.connectionId,
    required this.professionalName,
    required this.professionalSpecialty,
  });
}
