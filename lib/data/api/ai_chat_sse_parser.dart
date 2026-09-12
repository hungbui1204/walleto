import 'dart:convert';

import 'package:walleto/data/data.dart';
import 'package:walleto/shared/shared.dart';

class AiChatSseParser {
  const AiChatSseParser();

  Stream<AiChatStreamEventData> parse(Stream<List<int>> byteStream) async* {
    var sawDone = false;
    final accumulated = StringBuffer();

    await for (final line in utf8.decoder.bind(byteStream).transform(const LineSplitter())) {
      final event = _parseLine(line);
      if (event == null) {
        continue;
      }

      final type = event.type;
      if (type == AiChatSseConstants.typeStart) {
        continue;
      }

      if (type == AiChatSseConstants.typeStatus) {
        yield event;
        continue;
      }

      if (type == AiChatSseConstants.typeError) {
        throw RemoteException(
          kind: RemoteExceptionKind.serverDefined,
          httpErrorCode: 500,
          serverError: ServerError(generalMessage: event.error),
        );
      }

      if (type == AiChatSseConstants.typeDone) {
        sawDone = true;
        yield event;
        continue;
      }

      if (type == AiChatSseConstants.typePersisted) {
        yield event;
        return;
      }

      if (type == AiChatSseConstants.typeDelta) {
        if ((event.content ?? '').isEmpty) {
          continue;
        }
        accumulated.write(event.content);
        yield event;
      }
    }

    if (sawDone) {
      return;
    }

    final reply = accumulated.toString();
    if (reply.isEmpty) {
      throw const RemoteException(kind: RemoteExceptionKind.serverUndefined);
    }

    yield AiChatStreamEventData(type: AiChatSseConstants.typeDone, reply: reply);
  }

  AiChatStreamEventData? _parseLine(String line) {
    final trimmed = line.trim();
    if (trimmed.isEmpty || !trimmed.startsWith(AiChatSseConstants.dataPrefix)) {
      return null;
    }

    final payload = trimmed.substring(AiChatSseConstants.dataPrefix.length).trim();
    if (payload.isEmpty || payload == AiChatSseConstants.doneSentinel) {
      return null;
    }

    Object? decoded;
    try {
      decoded = jsonDecode(payload);
    } on FormatException {
      return null;
    }

    if (decoded is! Map) {
      return null;
    }

    return AiChatStreamEventData.fromJson(Map<String, dynamic>.from(decoded));
  }
}
