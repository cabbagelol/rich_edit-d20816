#import "RichEditPlugin.h"
#if __has_include(<rich_edit/rich_edit-Swift.h>)
#import <rich_edit/rich_edit-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "rich_edit-Swift.h"
#endif

@implementation RichEditPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftRichEditPlugin registerWithRegistrar:registrar];
}
@end
