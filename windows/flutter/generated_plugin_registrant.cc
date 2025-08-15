//
//  Generated file. Do not edit.
//

// clang-format off

#include "generated_plugin_registrant.h"

#include <image_clipboard/image_clipboard_plugin_c_api.h>
#include <open_dir_windows/open_dir_windows_plugin_c_api.h>
#include <pasteboard/pasteboard_plugin.h>

void RegisterPlugins(flutter::PluginRegistry* registry) {
  ImageClipboardPluginCApiRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("ImageClipboardPluginCApi"));
  OpenDirWindowsPluginCApiRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("OpenDirWindowsPluginCApi"));
  PasteboardPluginRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("PasteboardPlugin"));
}
