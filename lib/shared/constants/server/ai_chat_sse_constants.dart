class AiChatSseConstants {
  const AiChatSseConstants._();

  static const dataPrefix = 'data:';
  static const doneSentinel = '[DONE]';
  static const typeStart = 'start';
  static const typeStatus = 'status';
  static const typeDelta = 'delta';
  static const typeDone = 'done';
  static const typePersisted = 'persisted';
  static const typeError = 'error';
  static const statusLoadingContext = 'loading_context';
}
