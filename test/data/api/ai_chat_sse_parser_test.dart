import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:walleto/data/data.dart';
import 'package:walleto/shared/shared.dart';

void main() {
  const parser = AiChatSseParser();

  Stream<List<int>> bytes(String raw) => Stream<List<int>>.fromIterable([utf8.encode(raw)]);

  test('skips start frames and yields delta then done', () async {
    const raw =
        'data: {"type":"start"}\n'
        'data: {"type":"delta","content":"Hello "}\n'
        'data: {"type":"delta","content":"there"}\n'
        'data: {"type":"done","reply":"Hello there","model":"llama"}\n';

    final events = await parser.parse(bytes(raw)).toList();

    expect(events, hasLength(3));
    expect(events[0].type, AiChatSseConstants.typeDelta);
    expect(events[0].content, 'Hello ');
    expect(events[1].type, AiChatSseConstants.typeDelta);
    expect(events[1].content, 'there');
    expect(events[2].type, AiChatSseConstants.typeDone);
    expect(events[2].reply, 'Hello there');
    expect(events[2].model, 'llama');
  });

  test('skips heartbeat comments and still yields data frames', () async {
    const raw =
        ': keep-alive\n'
        '\n'
        'data: {"type":"delta","content":"Hi"}\n'
        ': keep-alive\n'
        '\n'
        'data: {"type":"done"}\n'
        ': keep-alive\n'
        '\n';

    final events = await parser.parse(bytes(raw)).toList();

    expect(events.map((event) => event.type), [
      AiChatSseConstants.typeDelta,
      AiChatSseConstants.typeDone,
    ]);
    expect(events.first.content, 'Hi');
  });

  test('yields persisted ids after done', () async {
    const raw =
        'data: {"type":"delta","content":"Hi"}\n'
        'data: {"type":"done"}\n'
        'data: {"type":"persisted","user_message_id":10,"assistant_message_id":11}\n';

    final events = await parser.parse(bytes(raw)).toList();

    expect(events.map((event) => event.type), [
      AiChatSseConstants.typeDelta,
      AiChatSseConstants.typeDone,
      AiChatSseConstants.typePersisted,
    ]);
    expect(events.last.userMessageId, 10);
    expect(events.last.assistantMessageId, 11);
  });

  test('yields status frames without throwing and still skips start', () async {
    const raw =
        'data: {"type":"start"}\n'
        'data: {"type":"status","status":"loading_context"}\n'
        'data: {"type":"delta","content":"Hi"}\n'
        'data: {"type":"done","reply":"Hi"}\n';

    final events = await parser.parse(bytes(raw)).toList();

    expect(events.map((event) => event.type), [
      AiChatSseConstants.typeStatus,
      AiChatSseConstants.typeDelta,
      AiChatSseConstants.typeDone,
    ]);
    expect(events.first.status, AiChatSseConstants.statusLoadingContext);
  });

  test('does not synthesize done from status frames when the stream ends without deltas', () async {
    const raw =
        'data: {"type":"start"}\n'
        'data: {"type":"status","status":"loading_context"}\n'
        ': keep-alive\n'
        '\n';

    await expectLater(
      parser.parse(bytes(raw)),
      emitsInOrder([
        isA<AiChatStreamEventData>()
            .having((event) => event.type, 'type', AiChatSseConstants.typeStatus)
            .having((event) => event.status, 'status', AiChatSseConstants.statusLoadingContext),
        emitsError(
          isA<RemoteException>().having((e) => e.kind, 'kind', RemoteExceptionKind.serverUndefined),
        ),
      ]),
    );
  });

  test('still synthesizes done from deltas when status frames are present', () async {
    const raw =
        'data: {"type":"status","status":"loading_context"}\n'
        'data: {"type":"delta","content":"partial"}\n';

    await expectLater(
      parser.parse(bytes(raw)),
      emitsInOrder([
        isA<AiChatStreamEventData>()
            .having((event) => event.type, 'type', AiChatSseConstants.typeStatus)
            .having((event) => event.status, 'status', AiChatSseConstants.statusLoadingContext),
        isA<AiChatStreamEventData>().having((event) => event.content, 'content', 'partial'),
        isA<AiChatStreamEventData>()
            .having((event) => event.type, 'type', AiChatSseConstants.typeDone)
            .having((event) => event.reply, 'reply', 'partial'),
        emitsDone,
      ]),
    );
  });

  test('parses frames split across byte chunks', () async {
    final chunked = Stream<List<int>>.fromIterable([
      utf8.encode('data: {"type":"delta","cont'),
      utf8.encode('ent":"Hi"}\ndata: {"type":"done","reply":"Hi"}\n'),
    ]);

    final events = await parser.parse(chunked).toList();

    expect(events.map((event) => event.type), [
      AiChatSseConstants.typeDelta,
      AiChatSseConstants.typeDone,
    ]);
    expect(events.first.content, 'Hi');
  });

  test('throws a server-defined exception for error frames', () async {
    const raw = 'data: {"type":"error","error":"Cloudflare AI request failed"}\n';

    await expectLater(
      parser.parse(bytes(raw)),
      emitsError(
        isA<RemoteException>()
            .having((e) => e.kind, 'kind', RemoteExceptionKind.serverDefined)
            .having((e) => e.generalServerMessage, 'message', 'Cloudflare AI request failed'),
      ),
    );
  });

  test('completes locally from accumulated deltas when the stream ends without done', () async {
    const raw = 'data: {"type":"delta","content":"partial"}\n';

    await expectLater(
      parser.parse(bytes(raw)),
      emitsInOrder([
        isA<AiChatStreamEventData>().having((event) => event.content, 'content', 'partial'),
        isA<AiChatStreamEventData>()
            .having((event) => event.type, 'type', AiChatSseConstants.typeDone)
            .having((event) => event.reply, 'reply', 'partial'),
        emitsDone,
      ]),
    );
  });

  test('throws when the stream ends without a done frame and without deltas', () async {
    const raw = 'data: {"type":"start"}\n: keep-alive\n\n';

    await expectLater(
      parser.parse(bytes(raw)),
      emitsError(
        isA<RemoteException>().having((e) => e.kind, 'kind', RemoteExceptionKind.serverUndefined),
      ),
    );
  });
}
