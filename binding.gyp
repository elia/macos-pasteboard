{
  "targets": [
    {
      "target_name": "macos_pasteboard",
      "sources": [
        "src/addon.mm"
      ],
      "include_dirs": [
        "<!@(node -p \"require('node-addon-api').include\")"
      ],
      "dependencies": [
        "<!(node -p \"require('node-addon-api').gyp\")"
      ],
      "defines": [
        "NAPI_DISABLE_CPP_EXCEPTIONS"
      ],
      "xcode_settings": {
        "CLANG_ENABLE_OBJC_ARC": "YES",
        "CLANG_CXX_LANGUAGE_STANDARD": "c++17",
        "MACOSX_DEPLOYMENT_TARGET": "10.13",
        "OTHER_LDFLAGS": [
          "-framework", "AppKit",
          "-framework", "Foundation"
        ]
      }
    }
  ]
}

