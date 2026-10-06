set(VCPKG_POLICY_EMPTY_PACKAGE enabled)

file(COPY "${CMAKE_CURRENT_LIST_DIR}/vcpkg-cmake-wrapper.cmake"
     DESTINATION "${CURRENT_PACKAGES_DIR}/share/opencv4")
