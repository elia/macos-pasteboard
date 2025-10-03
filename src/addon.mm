#import <AppKit/AppKit.h>
#include <napi.h>

// Compatibility aliases for older SDKs/macOS versions.
// Use string-literal fallbacks to avoid deprecation warnings from legacy symbols.
#ifndef NSPasteboardTypeString
#define NSPasteboardTypeString @"NSStringPboardType"
#endif
#ifndef NSPasteboardNameFind
#define NSPasteboardNameFind @"NSFindPboard"
#endif
#ifndef NSPasteboardNameFont
#define NSPasteboardNameFont @"NSFontPboard"
#endif
#ifndef NSPasteboardNameRuler
#define NSPasteboardNameRuler @"NSRulerPboard"
#endif
#ifndef NSPasteboardNameDrag
#define NSPasteboardNameDrag @"NSDragPboard"
#endif
#ifndef NSPasteboardNameColor
#define NSPasteboardNameColor NSColorPboard
#endif

static NSPasteboard* PasteboardFromName(const std::string& name) {
  @autoreleasepool {
    if (name.empty()) {
      return [NSPasteboard generalPasteboard];
    }

    NSString* ns = [NSString stringWithUTF8String:name.c_str()];
    NSString* lower = [ns lowercaseString];

    if ([lower isEqualToString:@"general"]) {
      return [NSPasteboard generalPasteboard];
    }
    if ([lower isEqualToString:@"find"]) {
      return [NSPasteboard pasteboardWithName:NSPasteboardNameFind];
    }
    if ([lower isEqualToString:@"font"]) {
      return [NSPasteboard pasteboardWithName:NSPasteboardNameFont];
    }
    if ([lower isEqualToString:@"ruler"]) {
      return [NSPasteboard pasteboardWithName:NSPasteboardNameRuler];
    }
    if ([lower isEqualToString:@"drag"]) {
      return [NSPasteboard pasteboardWithName:NSPasteboardNameDrag];
    }
    // No dedicated 'color' pasteboard; colors use types on general
    // Custom / arbitrary named pasteboard
    return [NSPasteboard pasteboardWithName:ns];
  }
}

static NSPasteboard* PasteboardFromArg(const Napi::CallbackInfo& info, size_t idx) {
  Napi::Env env = info.Env();
  if (info.Length() <= idx || info[idx].IsUndefined() || info[idx].IsNull()) {
    return PasteboardFromName("");
  }
  if (!info[idx].IsString()) {
    Napi::TypeError::New(env, "Expected pasteboard name to be a string").ThrowAsJavaScriptException();
    return nil;
  }
  std::string name = info[idx].As<Napi::String>().Utf8Value();
  return PasteboardFromName(name);
}

static Napi::Value ReadText(const Napi::CallbackInfo& info) {
  Napi::Env env = info.Env();
  @autoreleasepool {
    NSPasteboard* pb = PasteboardFromArg(info, 0);
    if (pb == nil) return env.Null();
    NSString* str = [pb stringForType:NSPasteboardTypeString];
    if (str == nil) {
      return env.Null();
    }
    std::string out([str UTF8String]);
    return Napi::String::New(env, out);
  }
}

static Napi::Value WriteText(const Napi::CallbackInfo& info) {
  Napi::Env env = info.Env();
  if (info.Length() < 1 || !info[0].IsString()) {
    Napi::TypeError::New(env, "Expected first argument to be the text string").ThrowAsJavaScriptException();
    return env.Undefined();
  }
  std::string text = info[0].As<Napi::String>().Utf8Value();
  @autoreleasepool {
    NSPasteboard* pb = PasteboardFromArg(info, 1);
    if (pb == nil) return Napi::Boolean::New(env, false);
    [pb clearContents];
    NSString* ns = [NSString stringWithUTF8String:text.c_str()];
    BOOL ok = [pb setString:ns forType:NSPasteboardTypeString];
    return Napi::Boolean::New(env, ok == YES);
  }
}

static Napi::Value Clear(const Napi::CallbackInfo& info) {
  Napi::Env env = info.Env();
  @autoreleasepool {
    NSPasteboard* pb = PasteboardFromArg(info, 0);
    if (pb == nil) return Napi::Boolean::New(env, false);
    NSInteger changeCount = [pb clearContents];
    return Napi::Boolean::New(env, changeCount >= 0);
  }
}

static Napi::Value HasText(const Napi::CallbackInfo& info) {
  Napi::Env env = info.Env();
  @autoreleasepool {
    NSPasteboard* pb = PasteboardFromArg(info, 0);
    if (pb == nil) return Napi::Boolean::New(env, false);
    NSString* available = [pb availableTypeFromArray:@[ NSPasteboardTypeString ]];
    return Napi::Boolean::New(env, available != nil);
  }
}

static Napi::Value Types(const Napi::CallbackInfo& info) {
  Napi::Env env = info.Env();
  @autoreleasepool {
    NSPasteboard* pb = PasteboardFromArg(info, 0);
    if (pb == nil) return env.Null();
    NSArray<NSPasteboardType>* types = [pb types];
    Napi::Array arr = Napi::Array::New(env, (size_t)[types count]);
    for (NSUInteger i = 0; i < [types count]; i++) {
      NSString* t = [types objectAtIndex:i];
      arr.Set((uint32_t)i, Napi::String::New(env, std::string([t UTF8String])));
    }
    return arr;
  }
}

static Napi::Value KnownPasteboards(const Napi::CallbackInfo& info) {
  Napi::Env env = info.Env();
  @autoreleasepool {
    Napi::Object obj = Napi::Object::New(env);
    obj.Set("general", Napi::String::New(env, "general"));
    obj.Set("find", Napi::String::New(env, std::string([NSPasteboardNameFind UTF8String])));
    obj.Set("font", Napi::String::New(env, std::string([NSPasteboardNameFont UTF8String])));
    obj.Set("ruler", Napi::String::New(env, std::string([NSPasteboardNameRuler UTF8String])));
    obj.Set("drag", Napi::String::New(env, std::string([NSPasteboardNameDrag UTF8String])));
    return obj;
  }
}

static Napi::Object Init(Napi::Env env, Napi::Object exports) {
  exports.Set(Napi::String::New(env, "readText"), Napi::Function::New(env, ReadText));
  exports.Set(Napi::String::New(env, "writeText"), Napi::Function::New(env, WriteText));
  exports.Set(Napi::String::New(env, "clear"), Napi::Function::New(env, Clear));
  exports.Set(Napi::String::New(env, "hasText"), Napi::Function::New(env, HasText));
  exports.Set(Napi::String::New(env, "types"), Napi::Function::New(env, Types));
  exports.Set(Napi::String::New(env, "knownPasteboards"), Napi::Function::New(env, KnownPasteboards));
  return exports;
}

NODE_API_MODULE(macos_pasteboard, Init)
