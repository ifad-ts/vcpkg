include(vcpkg_common_functions)

if (VCPKG_LIBRARY_LINKAGE STREQUAL static)
    message(STATUS "Warning: Static building will not support load data through plugins.")
    set(VCPKG_LIBRARY_LINKAGE dynamic)
endif()

if(VCPKG_CRT_LINKAGE STREQUAL static)
    message(FATAL_ERROR "osgworks does not support static CRT linkage")
endif()

file(GLOB OSG_PLUGINS_SUBDIR ${CURRENT_INSTALLED_DIR}/tools/osg/osgPlugins-*)
list(LENGTH OSG_PLUGINS_SUBDIR OSG_PLUGINS_SUBDIR_LENGTH)
if(NOT OSG_PLUGINS_SUBDIR_LENGTH EQUAL 1)
    message(FATAL_ERROR "Could not determine osg version")
endif()
string(REPLACE "${CURRENT_INSTALLED_DIR}/tools/osg/" "" OSG_PLUGINS_SUBDIR "${OSG_PLUGINS_SUBDIR}")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO mccdo/osgworks
    REF 7913605582edb875605663d655dc7740bfb6a8fe
    SHA512 13b60769ea9ccb80dbc7693d184271d02bf8a1117fefd8f63ab32b39c14ca0f446e1c1cdd99904322781a65f6a8ce4e160d84dda994b1d21d90a3e39795df8c3
    HEAD_REF master
)

# Replace the use of the bundled FindOSGHelper.cmake script with the vcpkg one (FindOSG).
vcpkg_apply_patches(
    SOURCE_PATH ${SOURCE_PATH}
    PATCHES "${CMAKE_CURRENT_LIST_DIR}/0001-find-osg.patch")

# delete bundled find script for OpenSceneGraph
#file(REMOVE_RECURSE ${SOURCE_PATH}/CMakeModules/FindOSGHelper.cmake)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
)

vcpkg_install_cmake()

# Handle copyright
file(COPY ${SOURCE_PATH}/LICENSE.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/osgworks)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/osgworks/LICENSE.txt ${CURRENT_PACKAGES_DIR}/share/osgworks/copyright)
