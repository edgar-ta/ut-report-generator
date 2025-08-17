//
//  Generated file. Do not edit.
//

// clang-format off

#include "generated_plugin_registrant.h"

#include <file_selector_windows/file_selector_windows.h>
#include <image_clipboard/image_clipboard_plugin_c_api.h>
#include <open_dir_windows/open_dir_windows_plugin_c_api.h>
#include <pasteboard/pasteboard_plugin.h>
#include <url_launcher_windows/url_launcher_windows.h>

void RegisterPlugins(flutter::PluginRegistry* registry) {
  FileSelectorWindowsRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("FileSelectorWindows"));
  ImageClipboardPluginCApiRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("ImageClipboardPluginCApi"));
  OpenDirWindowsPluginCApiRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("OpenDirWindowsPluginCApi"));
  PasteboardPluginRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("PasteboardPlugin"));
  UrlLauncherWindowsRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("UrlLauncherWindows"));
}
