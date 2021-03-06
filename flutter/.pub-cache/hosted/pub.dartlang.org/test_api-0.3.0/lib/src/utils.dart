// Copyright (c) 2013, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:async/async.dart';
import 'package:collection/collection.dart';
import 'package:matcher/matcher.dart';
import 'package:path/path.dart' as p;
import 'package:stream_channel/stream_channel.dart';
import 'package:term_glyph/term_glyph.dart' as glyph;

import 'backend/operating_system.dart';

/// A transformer that decodes bytes using UTF-8 and splits them on newlines.
final lineSplitter = StreamTransformer<List<int>, String>(
    (stream, cancelOnError) => utf8.decoder
        .bind(stream)
        .transform(const LineSplitter())
        .listen(null, cancelOnError: cancelOnError));

/// A [StreamChannelTransformer] that converts a chunked string channel to a
/// line-by-line channel.
///
/// Note that this is only safe for channels whose messages are guaranteed not
/// to contain newlines.
final chunksToLines = StreamChannelTransformer<String, String>(
    const LineSplitter(),
    StreamSinkTransformer.fromHandlers(
        handleData: (data, sink) => sink.add('$data\n')));

/// A regular expression to match the exception prefix that some exceptions'
/// [Object.toString] values contain.
final _exceptionPrefix = RegExp(r'^([A-Z][a-zA-Z]*)?(Exception|Error): ');

/// A regular expression matching a single vowel.
final _vowel = RegExp('[aeiou]');

/// Directories that are specific to OS X.
///
/// This is used to try to distinguish OS X and Linux in [currentOSGuess].
final _macOSDirectories = {
  '/Applications',
  '/Library',
  '/Network',
  '/System',
  '/Users',
};

/// Returns the best guess for the current operating system without using
/// `dart:io`.
///
/// This is useful for running test files directly and skipping tests as
/// appropriate. The only OS-specific information we have is the current path,
/// which we try to use to figure out the OS.
final OperatingSystem currentOSGuess = (() {
  if (p.style == p.Style.url) return OperatingSystem.none;
  if (p.style == p.Style.windows) return OperatingSystem.windows;
  if (_macOSDirectories.any(p.current.startsWith)) return OperatingSystem.macOS;
  return OperatingSystem.linux;
})();

/// A regular expression matching a hyphenated identifier.
///
/// This is like a standard Dart identifier, except that it can also contain
/// hyphens.
final _hyphenatedIdentifier = RegExp(r'[a-zA-Z_-][a-zA-Z0-9_-]*');

/// Like [_hyphenatedIdentifier], but anchored so that it must match the entire
/// string.
final anchoredHyphenatedIdentifier =
    RegExp('^${_hyphenatedIdentifier.pattern}\$');

/// A pair of values.
class Pair<E, F> {
  E first;
  F last;

  Pair(this.first, this.last);

  @override
  String toString() => '($first, $last)';

  @override
  bool operator ==(other) {
    if (other is! Pair) return false;
    return other.first == first && other.last == last;
  }

  @override
  int get hashCode => first.hashCode ^ last.hashCode;
}

/// Get a string description of an exception.
///
/// Many exceptions include the exception class name at the beginning of their
/// [toString], so we remove that if it exists.
String getErrorMessage(error) =>
    error.toString().replaceFirst(_exceptionPrefix, '');

/// Indent each line in [string] by [size] spaces.
///
/// If [first] is passed, it's used in place of the first line's indentation and
/// [size] defaults to `first.length`. Otherwise, [size] defaults to 2.
String indent(String string, {int? size, String? first}) {
  size ??= first == null ? 2 : first.length;
  return prefixLines(string, ' ' * size, first: first);
}

/// Returns a sentence fragment listing the elements of [iter].
///
/// This converts each element of [iter] to a string and separates them with
/// commas and/or [conjunction] where appropriate. The [conjunction] defaults to
/// "and".
String toSentence(Iterable iter, {String conjunction = 'and'}) {
  if (iter.length == 1) return iter.first.toString();

  var result = iter.take(iter.length - 1).join(', ');
  if (iter.length > 2) result += ',';
  return '$result $conjunction ${iter.last}';
}

/// Returns [name] if [number] is 1, or the plural of [name] otherwise.
///
/// By default, this just adds "s" to the end of [name] to get the plural. If
/// [plural] is passed, that's used instead.
String pluralize(String name, int number, {String? plural}) {
  if (number == 1) return name;
  if (plural != null) return plural;
  return '${name}s';
}

/// Returns [noun] with an indefinite article ("a" or "an") added, based on
/// whether its first letter is a vowel.
String a(String noun) => noun.startsWith(_vowel) ? 'an $noun' : 'a $noun';

/// A regular expression matching terminal color codes.
final _colorCode = RegExp('\u001b\\[[0-9;]+m');

/// Returns [str] without any color codes.
String withoutColors(String str) => str.replaceAll(_colorCode, '');

/// Like [mergeMaps], but assumes both maps are unmodifiable and so avoids
/// creating a new map unnecessarily.
///
/// The return value *may or may not* be unmodifiable.
Map<K, V> mergeUnmodifiableMaps<K, V>(Map<K, V> map1, Map<K, V> map2,
    {V Function(V, V)? value}) {
  if (map1.isEmpty) return map2;
  if (map2.isEmpty) return map1;
  return mergeMaps(map1, map2, value: value);
}

/// Truncates [text] to fit within [maxLength].
///
/// This will try to truncate along word boundaries and preserve words both at
/// the beginning and the end of [text].
String truncate(String text, int maxLength) {
  // Return the full message if it fits.
  if (text.length <= maxLength) return text;

  // If we can fit the first and last three words, do so.
  var words = text.split(' ');
  if (words.length > 1) {
    var i = words.length;
    var length = words.first.length + 4;
    do {
      i--;
      length += 1 + words[i].length;
    } while (length <= maxLength && i > 0);
    if (length > maxLength || i == 0) i++;
    if (i < words.length - 4) {
      // Require at least 3 words at the end.
      var buffer = StringBuffer();
      buffer.write(words.first);
      buffer.write(' ...');
      for (; i < words.length; i++) {
        buffer.write(' ');
        buffer.write(words[i]);
      }
      return buffer.toString();
    }
  }

  // Otherwise truncate to return the trailing text, but attempt to start at
  // the beginning of a word.
  var result = text.substring(text.length - maxLength + 4);
  var firstSpace = result.indexOf(' ');
  if (firstSpace > 0) {
    result = result.substring(firstSpace);
  }
  return '...$result';
}

/// Returns a human-friendly representation of [duration].
String niceDuration(Duration duration) {
  var minutes = duration.inMinutes;
  var seconds = duration.inSeconds % 60;
  var decaseconds = (duration.inMilliseconds % 1000) ~/ 100;

  var buffer = StringBuffer();
  if (minutes != 0) buffer.write('$minutes minutes');

  if (minutes == 0 || seconds != 0) {
    if (minutes != 0) buffer.write(', ');
    buffer.write(seconds);
    if (decaseconds != 0) buffer.write('.$decaseconds');
    buffer.write(' seconds');
  }

  return buffer.toString();
}

/// Returns a single-subscription stream that emits the results of [operations]
/// in the order they complete.
///
/// If the subscription is canceled, any pending operations are canceled as
/// well.
Stream<T> inCompletionOrder<T>(Iterable<CancelableOperation<T>> operations) {
  var operationSet = operations.toSet();
  var controller = StreamController<T>(
      sync: true,
      onCancel: () {
        return Future.wait(operationSet.map((operation) => operation.cancel()));
      });

  for (var operation in operationSet) {
    operation.value
        .then((value) => controller.add(value))
        .onError(controller.addError)
        .whenComplete(() {
      operationSet.remove(operation);
      if (operationSet.isEmpty) controller.close();
    });
  }

  return controller.stream;
}

/// Returns a random base64 string containing [bytes] bytes of data.
///
/// [seed] is passed to [math.Random].
String randomBase64(int bytes, {int? seed}) {
  var random = math.Random(seed);
  var data = Uint8List(bytes);
  for (var i = 0; i < bytes; i++) {
    data[i] = random.nextInt(256);
  }
  return base64Encode(data);
}

/// Throws an [ArgumentError] if [message] isn't recursively JSON-safe.
void ensureJsonEncodable(Object? message) {
  if (message == null ||
      message is String ||
      message is num ||
      message is bool) {
    // JSON-encodable, hooray!
  } else if (message is List) {
    for (var element in message) {
      ensureJsonEncodable(element);
    }
  } else if (message is Map) {
    message.forEach((key, value) {
      if (key is! String) {
        throw ArgumentError("$message can't be JSON-encoded.");
      }

      ensureJsonEncodable(value);
    });
  } else {
    throw ArgumentError.value("$message can't be JSON-encoded.");
  }
}

/// Indents [text], and adds a bullet at the beginning.
String addBullet(String text) =>
    prefixLines(text, '  ', first: '${glyph.bullet} ');

/// Converts [strings] to a bulleted list.
String bullet(Iterable<String> strings) => strings.map(addBullet).join('\n');

/// Prepends each line in [text] with [prefix].
///
/// If [first] or [last] is passed, the first and last lines, respectively, are
/// prefixed with those instead. If [single] is passed, it's used if there's
/// only a single line; otherwise, [first], [last], or [prefix] is used, in that
/// order of precedence.
String prefixLines(String text, String prefix,
    {String? first, String? last, String? single}) {
  single ??= first ?? last ?? prefix;
  first ??= prefix;
  last ??= prefix;

  var lines = text.split('\n');
  if (lines.length == 1) return '$single$text';

  var buffer = StringBuffer('$first${lines.first}\n');

  // Write out all but the first and last lines with [prefix].
  for (var line in lines.skip(1).take(lines.length - 2)) {
    buffer.writeln('$prefix$line');
  }
  buffer.write('$last${lines.last}');
  return buffer.toString();
}

/// Returns a pretty-printed representation of [value].
///
/// The matcher package doesn't expose its pretty-print function directly, but
/// we can use it through StringDescription.
String prettyPrint(value) =>
    StringDescription().addDescriptionOf(value).toString();

/// Indicates to tools that [future] is intentionally not `await`-ed.
///
/// In an `async` context, it is normally expected that all [Future]s are
/// awaited, and that is the basis of the lint `unawaited_futures`. However,
/// there are times where one or more futures are intentionally not awaited.
/// This function may be used to ignore a particular future. It silences the
/// `unawaited_futures` lint.
void unawaited(Future<void> future) {}
