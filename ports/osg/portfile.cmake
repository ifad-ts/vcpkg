# Common Ambient Variables:
#   CURRENT_BUILDTREES_DIR    = ${VCPKG_ROOT_DIR}\buildtrees\${PORT}
#   CURRENT_PACKAGES_DIR      = ${VCPKG_ROOT_DIR}\packages\${PORT}_${TARGET_TRIPLET}
#   CURRENT_PORT_DIR          = ${VCPKG_ROOT_DIR}\ports\${PORT}
#   PORT                      = current port name (zlib, etc)
#   TARGET_TRIPLET            = current triplet (x86-windows, x64-windows-static, etc)
#   VCPKG_CRT_LINKAGE         = C runtime linkage type (static, dynamic)
#   VCPKG_LIBRARY_LINKAGE     = target library linkage type (static, dynamic)
#   VCPKG_ROOT_DIR            = <C:\path\to\current\vcpkg>
#   VCPKG_TARGET_ARCHITECTURE = target architecture (x64, x86, arm)
#

include(vcpkg_common_functions)
if (VCPKG_LIBRARY_LINKAGE STREQUAL static)
    message(STATUS "Warning: Static building will not support load data through plugins.")
    set(VCPKG_LIBRARY_LINKAGE dynamic)
endif()

#vcpkg_from_github(
#	OUT_SOURCE_PATH SOURCE_PATH
#	REPO openscenegraph/OpenSceneGraph
#	REF OpenSceneGraph-3.2.1-rc3
#	SHA512 369c0790ad990cc0f5403209b6e8afe73069f4a467883f9031ac0539bdd090f2cd71487285e515da39bb5a5f67a15548edd479d489dc57374b481ed32ebed0eb
#	HEAD_REF master
#)

# Paths used in build
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/OpenSceneGraph)
set(COPY_FROM C:/Users/michael/Development/IFAD-SVN/vendorSRC/OpenSceneGraph)
message(STATUS "Copying files from ${COPY_FROM} TO ${SOURCE_PATH}")
file(COPY ${COPY_FROM} DESTINATION ${CURRENT_BUILDTREES_DIR} PATTERN ".svn" EXCLUDE)

#export https://svn.ifad.dk/svn/IFAD/vendorSRC/OpenSceneGraph/tags/3.2.1.4 ${SOURCE_PATH}

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    # PREFER_NINJA # Disable this option if project cannot be built with Ninja
    OPTIONS
        -DOSG_USE_UTF8_FILENAME=ON
        -DOSG_USE_QT=OFF
    # OPTIONS_RELEASE -DOPTIMIZE=1
    # OPTIONS_DEBUG -DDEBUGGABLE=1
)

vcpkg_install_cmake()

# handle osg tools and plugins 
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

set(OSG_TOOL_PATH ${CURRENT_PACKAGES_DIR}/tools/osg)
file(MAKE_DIRECTORY ${OSG_TOOL_PATH})

file(GLOB OSG_TOOLS ${CURRENT_PACKAGES_DIR}/bin/*.exe)
file(COPY ${OSG_TOOLS} DESTINATION ${OSG_TOOL_PATH})
file(REMOVE_RECURSE ${OSG_TOOLS})
file(GLOB OSG_TOOLS_DBG ${CURRENT_PACKAGES_DIR}/debug/bin/*.exe)
file(REMOVE_RECURSE ${OSG_TOOLS_DBG})

file(GLOB OSG_PLUGINS_DBG ${CURRENT_PACKAGES_DIR}/debug/bin/osgPlugins-3.2.1/*.dll)
file(COPY ${OSG_PLUGINS_DBG} DESTINATION ${CURRENT_PACKAGES_DIR}/debug/tools/osg/osgPlugins-3.2.1)
file(GLOB OSG_PLUGINS_REL ${CURRENT_PACKAGES_DIR}/bin/osgPlugins-3.2.1/*.dll)
file(COPY ${OSG_PLUGINS_REL} DESTINATION ${OSG_TOOL_PATH}/osgPlugins-3.2.1)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/bin/osgPlugins-3.2.1/)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin/osgPlugins-3.2.1/)

# Handle copyright
file(COPY ${SOURCE_PATH}/LICENSE.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/osg)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/osg/LICENSE.txt ${CURRENT_PACKAGES_DIR}/share/osg/copyright)
