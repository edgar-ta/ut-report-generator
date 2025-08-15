//
//  Generated file. Do not edit.
//

import FlutterMacOS
import Foundation

import file_picker
import image_clipboard
import open_dir_macos
import open_file_mac
import pasteboard

func RegisterGeneratedPlugins(registry: FlutterPluginRegistry) {
  FilePickerPlugin.register(with: registry.registrar(forPlugin: "FilePickerPlugin"))
  ImageClipboardPlugin.register(with: registry.registrar(forPlugin: "ImageClipboardPlugin"))
  OpenDirMacosPlugin.register(with: registry.registrar(forPlugin: "OpenDirMacosPlugin"))
  OpenFilePlugin.register(with: registry.registrar(forPlugin: "OpenFilePlugin"))
  PasteboardPlugin.register(with: registry.registrar(forPlugin: "PasteboardPlugin"))
}
