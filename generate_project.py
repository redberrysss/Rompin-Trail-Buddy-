#!/usr/bin/env python3
"""Generate Xcode project.pbxproj for NatureTherapyAI"""

import hashlib
import os

def uuid(name):
    return hashlib.md5(name.encode()).hexdigest()[:24].upper()

PROJECT_DIR = "NatureTherapyAI.xcodeproj"
os.makedirs(PROJECT_DIR, exist_ok=True)

ROOT_UUID = uuid("root_group")
PROJECT_UUID = uuid("project")
MAIN_GROUP_UUID = uuid("main_group")
PRODUCTS_GROUP_UUID = uuid("products_group")
APP_TARGET_UUID = uuid("app_target")
APP_PRODUCT_UUID = uuid("app_product")
PROJECT_CONFIG_LIST_UUID = uuid("project_config_list")
TARGET_CONFIG_LIST_UUID = uuid("target_config_list")
DEBUG_CONFIG_UUID = uuid("debug_config")
RELEASE_CONFIG_UUID = uuid("release_config")
DEBUG_CONFIG_IOS_UUID = uuid("debug_config_ios")
RELEASE_CONFIG_IOS_UUID = uuid("release_config_ios")
SOURCES_BUILD_PHASE = uuid("sources_phase")
RESOURCES_BUILD_PHASE = uuid("resources_phase")
ASSETS_CATALOG_BUILD_UUID = uuid("assets_build")
ASSETS_REF = uuid("assets_ref")
INFO_PLIST_REF = uuid("infoplist_ref")

SOURCE_FILES = [
    "App/NatureTherapyAIApp.swift",
    "App/Theme.swift",
    "Views/Auth/RootView.swift",
    "Views/Auth/LoginView.swift",
    "Views/Auth/RegisterView.swift",
    "Views/Auth/ForgotPasswordView.swift",
    "Views/Auth/AccountView.swift",
    "Views/ParticipantSelectionView.swift",
    "Views/HomeDashboardView.swift",
    "Views/SettingsView.swift",
    "Views/CameraView.swift",
    "Views/DiscoveryView.swift",
    "Views/HomeView.swift",
    "Views/ProgressView.swift",
    "Views/TherapyView.swift",
    "Views/FacilitatorModePlaceholder.swift",
    "Views/Facilitator/FacilitatorDashboardView.swift",
    "Views/Facilitator/FacilitatorParticipantDetailView.swift",
    "Views/Activity1NatureWalkView.swift",
    "Views/Activity2SensoryView.swift",
    "Views/Activity3TreasureHuntView.swift",
    "Views/Activity4NatureArtView.swift",
    "Views/Components/VisualInstructionCard.swift",
    "Views/Components/LargeActionButton.swift",
    "Views/Components/ProgressHeader.swift",
    "Views/Components/EmotionCard.swift",
    "Views/Components/CameraCaptureView.swift",
    "Views/Components/PhotoPreviewView.swift",
    "Views/Components/ObservationItemCard.swift",
    "Views/Components/SensoryStationCard.swift",
    "Views/Components/TreasureItemCard.swift",
    "Views/Components/BoundingBoxOverlay.swift",
    "Views/Components/BreathingAnimation.swift",
    "Views/Components/NatureDrawingCanvas.swift",
    "Views/Components/BadgeView.swift",
    "Views/Components/ActivityCard.swift",
    "Camera/CameraManager.swift",
    "Camera/CameraPreview.swift",
    "Camera/SimulatorCameraManager.swift",
    "AI/ObjectDetector.swift",
    "AI/VisionProcessor.swift",
    "AI/ModelHandler.swift",
    "AI/RoboflowModelManager.swift",
    "Models/Participant.swift",
    "Models/ActivitySession.swift",
    "Models/ObservationRecord.swift",
    "Models/SensoryRecord.swift",
    "Models/TreasureRecord.swift",
    "Models/ArtworkRecord.swift",
    "Models/DetectionResult.swift",
    "Models/NatureObject.swift",
    "Models/ChildProgress.swift",
    "Models/FirestoreModels.swift",
    "ViewModels/Activity1ViewModel.swift",
    "ViewModels/Activity2ViewModel.swift",
    "ViewModels/Activity3ViewModel.swift",
    "ViewModels/Activity4ViewModel.swift",
    "ViewModels/AuthenticationViewModel.swift",
    "ViewModels/CameraViewModel.swift",
    "ViewModels/DiscoveryViewModel.swift",
    "ViewModels/TherapyViewModel.swift",
    "ViewModels/ProgressViewModel.swift",
    "ViewModels/HomeViewModel.swift",
    "Services/ObjectDetectionService.swift",
    "Services/RoboflowAPIService.swift",
    "Services/ImageStorageService.swift",
    "Services/AudioStorageService.swift",
    "Services/DatabaseService.swift",
    "Services/DetectionService.swift",
    "Services/ProgressService.swift",
    "Services/AuthenticationService.swift",
    "Services/FirebaseStorageService.swift",
    "Services/PendingUploadService.swift",
    "Services/DataMigrationService.swift",
    "Services/Repositories/Protocols.swift",
    "Services/Repositories/FirebaseParticipantRepository.swift",
    "Services/Repositories/FirebaseSessionRepository.swift",
    "Services/Repositories/FirebaseObservationRepository.swift",
]

file_uuids = {}
build_uuids = {}
for f in SOURCE_FILES:
    file_uuids[f] = uuid(f"file_{f}")
    build_uuids[f] = uuid(f"build_{f}")

lines = []
lines.append('// !$*UTF8*$!')
lines.append('{')
lines.append('\tarchiveVersion = 1;')
lines.append('\tclasses = {')
lines.append('\t};')
lines.append('\tobjectVersion = 56;')
lines.append('\tobjects = {')

# PBXBuildFile section
lines.append('')
lines.append('/* Begin PBXBuildFile section */')
for f in SOURCE_FILES:
    b = build_uuids[f]
    lines.append(f'\t\t{b} /* {f} in Sources */ = {{isa = PBXBuildFile; fileRef = {file_uuids[f]}; }};')
lines.append(f'\t\t{ASSETS_CATALOG_BUILD_UUID} /* Assets.xcassets in Resources */ = {{isa = PBXBuildFile; fileRef = {ASSETS_REF}; }};')
lines.append('/* End PBXBuildFile section */')

# PBXFileReference section
lines.append('')
lines.append('/* Begin PBXFileReference section */')
for f in SOURCE_FILES:
    lines.append(f'\t\t{file_uuids[f]} /* {f} */ = {{isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = {f}; sourceTree = "<group>"; }};')
lines.append(f'\t\t{ASSETS_REF} /* Assets.xcassets */ = {{isa = PBXFileReference; lastKnownFileType = folder.assetcatalog; path = Assets.xcassets; sourceTree = "<group>"; }};')
lines.append(f'\t\t{INFO_PLIST_REF} /* Info.plist */ = {{isa = PBXFileReference; lastKnownFileType = text.plist.xml; path = Info.plist; sourceTree = "<group>"; }};')
lines.append(f'\t\t{APP_PRODUCT_UUID} /* Rompin Forest Explorer.app */ = {{isa = PBXFileReference; explicitFileType = wrapper.application; includeInIndex = 0; path = "Rompin Forest Explorer.app"; sourceTree = BUILT_PRODUCTS_DIR; }};')
lines.append('/* End PBXFileReference section */')

# PBXGroup section
lines.append('')
lines.append('/* Begin PBXGroup section */')
lines.append(f'\t\t{ROOT_UUID} = {{')
lines.append('\t\t\tisa = PBXGroup;')
lines.append('\t\t\tchildren = (')
lines.append(f'\t\t\t\t{MAIN_GROUP_UUID} /* NatureTherapyAI */,')
lines.append(f'\t\t\t\t{PRODUCTS_GROUP_UUID} /* Products */,')
lines.append('\t\t\t);')
lines.append('\t\t\tsourceTree = "<group>";')
lines.append('\t\t};')
lines.append(f'\t\t{MAIN_GROUP_UUID} = {{')
lines.append('\t\t\tisa = PBXGroup;')
lines.append('\t\t\tchildren = (')
lines.append(f'\t\t\t\t{INFO_PLIST_REF} /* Info.plist */,')
lines.append(f'\t\t\t\t{ASSETS_REF} /* Assets.xcassets */,')
for f in SOURCE_FILES:
    lines.append(f'\t\t\t\t{file_uuids[f]} /* {f} */,')
lines.append('\t\t\t);')
lines.append('\t\t\tpath = NatureTherapyAI;')
lines.append('\t\t\tsourceTree = "<group>";')
lines.append('\t\t};')
lines.append(f'\t\t{PRODUCTS_GROUP_UUID} = {{')
lines.append('\t\t\tisa = PBXGroup;')
lines.append('\t\t\tchildren = (')
lines.append(f'\t\t\t\t{APP_PRODUCT_UUID} /* Rompin Forest Explorer.app */,')
lines.append('\t\t\t);')
lines.append('\t\t\tname = Products;')
lines.append('\t\t\tsourceTree = "<group>";')
lines.append('\t\t};')
lines.append('/* End PBXGroup section */')

# PBXNativeTarget section
lines.append('')
lines.append('/* Begin PBXNativeTarget section */')
lines.append(f'\t\t{APP_TARGET_UUID} = {{')
lines.append('\t\t\tisa = PBXNativeTarget;')
lines.append(f'\t\t\tbuildConfigurationList = {TARGET_CONFIG_LIST_UUID};')
lines.append('\t\t\tbuildPhases = (')
lines.append(f'\t\t\t\t{SOURCES_BUILD_PHASE} /* Sources */,')
lines.append(f'\t\t\t\t{RESOURCES_BUILD_PHASE} /* Resources */,')
lines.append('\t\t\t);')
lines.append('\t\t\tbuildRules = (')
lines.append('\t\t\t);')
lines.append('\t\t\tdependencies = (')
lines.append('\t\t\t);')
lines.append('\t\t\tname = NatureTherapyAI;')
lines.append('\t\t\tproductName = NatureTherapyAI;')
lines.append(f'\t\t\tproductReference = {APP_PRODUCT_UUID};')
lines.append('\t\t\tproductType = "com.apple.product-type.application";')
lines.append('\t\t};')
lines.append('/* End PBXNativeTarget section */')

# PBXProject section
lines.append('')
lines.append('/* Begin PBXProject section */')
lines.append(f'\t\t{PROJECT_UUID} = {{')
lines.append('\t\t\tisa = PBXProject;')
lines.append('\t\t\tattributes = {')
lines.append('\t\t\t\tBuildIndependentTargetsInParallel = 1;')
lines.append('\t\t\t\tLastSwiftUpdateCheck = 1500;')
lines.append('\t\t\t\tLastUpgradeCheck = 1500;')
lines.append('\t\t\t};')
lines.append(f'\t\t\tbuildConfigurationList = {PROJECT_CONFIG_LIST_UUID};')
lines.append('\t\t\tcompatibilityVersion = "Xcode 14.0";')
lines.append('\t\t\tdevelopmentRegion = en;')
lines.append('\t\t\thasScannedForEncodings = 0;')
lines.append('\t\t\tknownRegions = (')
lines.append('\t\t\t\ten,')
lines.append('\t\t\t\tBase,')
lines.append('\t\t\t);')
lines.append(f'\t\t\tmainGroup = {ROOT_UUID};')
lines.append(f'\t\t\tproductRefGroup = {PRODUCTS_GROUP_UUID};')
lines.append('\t\t\tprojectDirPath = "";')
lines.append('\t\t\tprojectRoot = "";')
lines.append('\t\t\ttargets = (')
lines.append(f'\t\t\t\t{APP_TARGET_UUID},')
lines.append('\t\t\t);')
lines.append('\t\t};')
lines.append('/* End PBXProject section */')

# PBXResourcesBuildPhase
lines.append('')
lines.append('/* Begin PBXResourcesBuildPhase section */')
lines.append(f'\t\t{RESOURCES_BUILD_PHASE} = {{')
lines.append('\t\t\tisa = PBXResourcesBuildPhase;')
lines.append('\t\t\tbuildActionMask = 2147483647;')
lines.append('\t\t\tfiles = (')
lines.append(f'\t\t\t\t{ASSETS_CATALOG_BUILD_UUID} /* Assets.xcassets in Resources */,')
lines.append('\t\t\t);')
lines.append('\t\t\trunOnlyForDeploymentPostprocessing = 0;')
lines.append('\t\t};')
lines.append('/* End PBXResourcesBuildPhase section */')

# PBXSourcesBuildPhase
lines.append('')
lines.append('/* Begin PBXSourcesBuildPhase section */')
lines.append(f'\t\t{SOURCES_BUILD_PHASE} = {{')
lines.append('\t\t\tisa = PBXSourcesBuildPhase;')
lines.append('\t\t\tbuildActionMask = 2147483647;')
lines.append('\t\t\tfiles = (')
for f in SOURCE_FILES:
    b = build_uuids[f]
    lines.append(f'\t\t\t\t{b} /* {f} in Sources */,')
lines.append('\t\t\t);')
lines.append('\t\t\trunOnlyForDeploymentPostprocessing = 0;')
lines.append('\t\t};')
lines.append('/* End PBXSourcesBuildPhase section */')

# XCBuildConfiguration (project level)
lines.append('')
lines.append('/* Begin XCBuildConfiguration section */')
lines.append(f'\t\t{DEBUG_CONFIG_UUID} = {{')
lines.append('\t\t\tisa = XCBuildConfiguration;')
lines.append('\t\t\tbuildSettings = {')
lines.append('\t\t\t\tALWAYS_SEARCH_USER_PATHS = NO;')
lines.append('\t\t\t\tCLANG_ANALYZER_NONNULL = YES;')
lines.append('\t\t\t\tCLANG_CXX_LANGUAGE_STANDARD = "gnu++20";')
lines.append('\t\t\t\tCLANG_ENABLE_MODULES = YES;')
lines.append('\t\t\t\tCLANG_ENABLE_OBJC_ARC = YES;')
lines.append('\t\t\t\tCOPY_PHASE_STRIP = NO;')
lines.append('\t\t\t\tDEBUG_INFORMATION_FORMAT = dwarf;')
lines.append('\t\t\t\tENABLE_STRICT_OBJC_MSGSEND = YES;')
lines.append('\t\t\t\tENABLE_TESTABILITY = YES;')
lines.append('\t\t\t\tGCC_DYNAMIC_NO_PIC = NO;')
lines.append('\t\t\t\tGCC_OPTIMIZATION_LEVEL = 0;')
lines.append('\t\t\t\tGCC_PREPROCESSOR_DEFINITIONS = ( "DEBUG=1", "$(inherited)", );')
lines.append('\t\t\t\tIPHONEOS_DEPLOYMENT_TARGET = 17.0;')
lines.append('\t\t\t\tMTL_ENABLE_DEBUG_INFO = INCLUDE_SOURCE;')
lines.append('\t\t\t\tONLY_ACTIVE_ARCH = YES;')
lines.append('\t\t\t\tSDKROOT = iphoneos;')
lines.append('\t\t\t\tSWIFT_ACTIVE_COMPILATION_CONDITIONS = DEBUG;')
lines.append('\t\t\t\tSWIFT_OPTIMIZATION_LEVEL = "-Onone";')
lines.append('\t\t\t};')
lines.append('\t\t\tname = Debug;')
lines.append('\t\t};')
lines.append(f'\t\t{RELEASE_CONFIG_UUID} = {{')
lines.append('\t\t\tisa = XCBuildConfiguration;')
lines.append('\t\t\tbuildSettings = {')
lines.append('\t\t\t\tALWAYS_SEARCH_USER_PATHS = NO;')
lines.append('\t\t\t\tCLANG_ANALYZER_NONNULL = YES;')
lines.append('\t\t\t\tCLANG_CXX_LANGUAGE_STANDARD = "gnu++20";')
lines.append('\t\t\t\tCLANG_ENABLE_MODULES = YES;')
lines.append('\t\t\t\tCLANG_ENABLE_OBJC_ARC = YES;')
lines.append('\t\t\t\tCOPY_PHASE_STRIP = NO;')
lines.append('\t\t\t\tDEBUG_INFORMATION_FORMAT = "dwarf-with-dsym";')
lines.append('\t\t\t\tENABLE_NS_ASSERTIONS = NO;')
lines.append('\t\t\t\tENABLE_STRICT_OBJC_MSGSEND = YES;')
lines.append('\t\t\t\tGCC_OPTIMIZATION_LEVEL = s;')
lines.append('\t\t\t\tIPHONEOS_DEPLOYMENT_TARGET = 17.0;')
lines.append('\t\t\t\tMTL_ENABLE_DEBUG_INFO = NO;')
lines.append('\t\t\t\tSDKROOT = iphoneos;')
lines.append('\t\t\t\tSWIFT_COMPILATION_MODE = wholemodule;')
lines.append('\t\t\t\tSWIFT_OPTIMIZATION_LEVEL = "-O";')
lines.append('\t\t\t\tVALIDATE_PRODUCT = YES;')
lines.append('\t\t\t};')
lines.append('\t\t\tname = Release;')
lines.append('\t\t};')

# XCBuildConfiguration (target level)
lines.append(f'\t\t{DEBUG_CONFIG_IOS_UUID} = {{')
lines.append('\t\t\tisa = XCBuildConfiguration;')
lines.append('\t\t\tbuildSettings = {')
lines.append('\t\t\t\tASSETCATALOG_COMPILER_APPICON_NAME = AppIcon;')
lines.append('\t\t\t\tCODE_SIGN_STYLE = Automatic;')
lines.append('\t\t\t\tCURRENT_PROJECT_VERSION = 1;')
lines.append('\t\t\t\tENABLE_PREVIEWS = YES;')
lines.append('\t\t\t\tINFOPLIST_FILE = NatureTherapyAI/Info.plist;')
lines.append('\t\t\t\tINFOPLIST_KEY_CFBundleDisplayName = "Rompin Forest Explorer";')
lines.append('\t\t\t\tINFOPLIST_KEY_UIApplicationSceneManifest_Generation = YES;')
lines.append('\t\t\t\tINFOPLIST_KEY_UIApplicationSupportsIndirectInputEvents = YES;')
lines.append('\t\t\t\tINFOPLIST_KEY_UILaunchScreen_Generation = YES;')
lines.append('\t\t\t\tINFOPLIST_KEY_UISupportedInterfaceOrientations = UIInterfaceOrientationPortrait;')
lines.append('\t\t\t\tIPHONEOS_DEPLOYMENT_TARGET = 17.0;')
lines.append('\t\t\t\tLD_RUNPATH_SEARCH_PATHS = ( "$(inherited)", "@executable_path/Frameworks", );')
lines.append('\t\t\t\tMARKETING_VERSION = 1.0.0;')
lines.append('\t\t\t\tPRODUCT_BUNDLE_IDENTIFIER = com.naturetherapy.explorer;')
lines.append('\t\t\t\tPRODUCT_NAME = "Rompin Forest Explorer";')
lines.append('\t\t\t\tSWIFT_EMIT_LOC_STRINGS = YES;')
lines.append('\t\t\t\tSWIFT_VERSION = 5.0;')
lines.append('\t\t\t\tTARGETED_DEVICE_FAMILY = 1;')
lines.append('\t\t\t};')
lines.append('\t\t\tname = Debug;')
lines.append('\t\t};')
lines.append(f'\t\t{RELEASE_CONFIG_IOS_UUID} = {{')
lines.append('\t\t\tisa = XCBuildConfiguration;')
lines.append('\t\t\tbuildSettings = {')
lines.append('\t\t\t\tASSETCATALOG_COMPILER_APPICON_NAME = AppIcon;')
lines.append('\t\t\t\tCODE_SIGN_STYLE = Automatic;')
lines.append('\t\t\t\tCURRENT_PROJECT_VERSION = 1;')
lines.append('\t\t\t\tENABLE_PREVIEWS = YES;')
lines.append('\t\t\t\tINFOPLIST_FILE = NatureTherapyAI/Info.plist;')
lines.append('\t\t\t\tINFOPLIST_KEY_CFBundleDisplayName = "Rompin Forest Explorer";')
lines.append('\t\t\t\tINFOPLIST_KEY_UIApplicationSceneManifest_Generation = YES;')
lines.append('\t\t\t\tINFOPLIST_KEY_UIApplicationSupportsIndirectInputEvents = YES;')
lines.append('\t\t\t\tINFOPLIST_KEY_UILaunchScreen_Generation = YES;')
lines.append('\t\t\t\tINFOPLIST_KEY_UISupportedInterfaceOrientations = UIInterfaceOrientationPortrait;')
lines.append('\t\t\t\tIPHONEOS_DEPLOYMENT_TARGET = 17.0;')
lines.append('\t\t\t\tLD_RUNPATH_SEARCH_PATHS = ( "$(inherited)", "@executable_path/Frameworks", );')
lines.append('\t\t\t\tMARKETING_VERSION = 1.0.0;')
lines.append('\t\t\t\tPRODUCT_BUNDLE_IDENTIFIER = com.naturetherapy.explorer;')
lines.append('\t\t\t\tPRODUCT_NAME = "Rompin Forest Explorer";')
lines.append('\t\t\t\tSWIFT_EMIT_LOC_STRINGS = YES;')
lines.append('\t\t\t\tSWIFT_VERSION = 5.0;')
lines.append('\t\t\t\tTARGETED_DEVICE_FAMILY = 1;')
lines.append('\t\t\t};')
lines.append('\t\t\tname = Release;')
lines.append('\t\t};')
lines.append('/* End XCBuildConfiguration section */')

# XCConfigurationList
lines.append('')
lines.append('/* Begin XCConfigurationList section */')
lines.append(f'\t\t{PROJECT_CONFIG_LIST_UUID} = {{')
lines.append('\t\t\tisa = XCConfigurationList;')
lines.append('\t\t\tbuildConfigurations = (')
lines.append(f'\t\t\t\t{DEBUG_CONFIG_UUID},')
lines.append(f'\t\t\t\t{RELEASE_CONFIG_UUID},')
lines.append('\t\t\t);')
lines.append('\t\t\tdefaultConfigurationIsVisible = 0;')
lines.append('\t\t\tdefaultConfigurationName = Release;')
lines.append('\t\t};')
lines.append(f'\t\t{TARGET_CONFIG_LIST_UUID} = {{')
lines.append('\t\t\tisa = XCConfigurationList;')
lines.append('\t\t\tbuildConfigurations = (')
lines.append(f'\t\t\t\t{DEBUG_CONFIG_IOS_UUID},')
lines.append(f'\t\t\t\t{RELEASE_CONFIG_IOS_UUID},')
lines.append('\t\t\t);')
lines.append('\t\t\tdefaultConfigurationIsVisible = 0;')
lines.append('\t\t\tdefaultConfigurationName = Release;')
lines.append('\t\t};')
lines.append('/* End XCConfigurationList section */')

lines.append('\t};')
lines.append(f'\trootObject = {PROJECT_UUID};')
lines.append('}')

output = '\n'.join(lines)

with open(f"{PROJECT_DIR}/project.pbxproj", 'w') as f:
    f.write(output)

print(f"✅ Xcode project generated at {PROJECT_DIR}/project.pbxproj")
print(f"   {len(SOURCE_FILES)} source files registered")
