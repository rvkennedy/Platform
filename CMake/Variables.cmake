include_guard()

option( SIMUL_SOURCE_BUILD "Build Simul libraries from source? If false, only samples are built." ON )
set( VULKAN_SDK_DIR "$ENV{VULKAN_SDK}" CACHE STRING "Set the location of the Vulkan SDK directory." )

if(${CMAKE_SYSTEM_NAME} MATCHES "Windows" OR ${CMAKE_SYSTEM_NAME} MATCHES "Linux")
	option(SIMUL_SUPPORT_VULKAN "" ON )
else()
	option(SIMUL_SUPPORT_VULKAN "" OFF )
endif()
 
if(${CMAKE_SYSTEM_NAME} MATCHES "Windows")
	set( WINDOWS ON )
	option(SIMUL_SUPPORT_OPENGL "" ON)
	option(SIMUL_SUPPORT_D3D11 "" ON )
	option(SIMUL_SUPPORT_D3D12 "" ON )
else()
	option(SIMUL_SUPPORT_D3D11 "" OFF )
	option(SIMUL_SUPPORT_OPENGL "" OFF )
	if(XBOXONE)
		option(SIMUL_SUPPORT_D3D12 "" ON )
	else()
		if(GDK)
			option(SIMUL_SUPPORT_D3D12 "" ON)
		else()
			option(SIMUL_SUPPORT_D3D12 "" OFF )
		endif()
	endif()
endif()

if(${CMAKE_SYSTEM_NAME} MATCHES "PS4" )
	set(SIMUL_SUPPORT_PS4 ON)
else()
	set(SIMUL_SUPPORT_PS4 OFF)
endif()

if(${CMAKE_SYSTEM_NAME} MATCHES "Windows")
	set( BISON_EXECUTABLE "${CMAKE_SOURCE_DIR}/Platform/External/win_flex_bison/win_bison.exe" CACHE STRING "" )
	set( FLEX_EXECUTABLE "${CMAKE_SOURCE_DIR}/Platform/External/win_flex_bison/win_flex.exe" CACHE STRING "" )
	set( FLEX_INCLUDE_DIR "${CMAKE_SOURCE_DIR}/Platform/External/win_flex_bison/" CACHE STRING "" )
endif()

set( SIMUL_FX_EXECUTABLE "C:/Program Files (x86)/Windows Kits/10/bin/x64/fxc.exe" CACHE STRING "" )

if(${CMAKE_SYSTEM_NAME} MATCHES "Linux")
	set(SIMUL_SFX_EXECUTABLE "${CMAKE_BINARY_DIR}/bin/Sfx" CACHE STRING "" )
else()
	set(SIMUL_SFX_EXECUTABLE "${CMAKE_BINARY_DIR}/bin/Release/Sfx.exe" CACHE STRING "" )
endif()


# Defaults for glfw
set(GLFW_BUILD_TESTS OFF )
set(GLFW_BUILD_DOCS OFF )
set(GLFW_BUILD_EXAMPLES OFF )