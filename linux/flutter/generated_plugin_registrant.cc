//
//  Generated file. Do not edit.
//

// clang-format off

#include "generated_plugin_registrant.h"

#include <image_clipboard/image_clipboard_plugin.h>
#include <open_dir_linux/open_dir_linux_plugin.h>
#include <open_file_linux/open_file_linux_plugin.h>
#include <pasteboard/pasteboard_plugin.h>

void fl_register_plugins(FlPluginRegistry* registry) {
  g_autoptr(FlPluginRegistrar) image_clipboard_registrar =
      fl_plugin_registry_get_registrar_for_plugin(registry, "ImageClipboardPlugin");
  image_clipboard_plugin_register_with_registrar(image_clipboard_registrar);
  g_autoptr(FlPluginRegistrar) open_dir_linux_registrar =
      fl_plugin_registry_get_registrar_for_plugin(registry, "OpenDirLinuxPlugin");
  open_dir_linux_plugin_register_with_registrar(open_dir_linux_registrar);
  g_autoptr(FlPluginRegistrar) open_file_linux_registrar =
      fl_plugin_registry_get_registrar_for_plugin(registry, "OpenFileLinuxPlugin");
  open_file_linux_plugin_register_with_registrar(open_file_linux_registrar);
  g_autoptr(FlPluginRegistrar) pasteboard_registrar =
      fl_plugin_registry_get_registrar_for_plugin(registry, "PasteboardPlugin");
  pasteboard_plugin_register_with_registrar(pasteboard_registrar);
}
