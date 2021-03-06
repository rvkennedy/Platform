cmake_minimum_required(VERSION 2.8)

file(GLOB SOURCES "*.cpp" )
file(GLOB HEADERS "*.h" )

file(GLOB SHADERS
	"${SIMUL_PLATFORM_DIR}/Shaders/SFX/*.sfx"
)

file(GLOB SHADER_INCLUDES
	"${SIMUL_PLATFORM_DIR}/Shaders/SL/*.sl"
	"${SIMUL_PLATFORM_DIR}/Vulkan/GLSL/*.sl"
)

file(GLOB SHADER_DEFS
	"${SIMUL_PLATFORM_DIR}/Vulkan/GLSL/*.*" 
)

add_static_library( SimulVulkan SOURCES ${SOURCES} ${HEADERS} DEFINITIONS SIMUL_VULKAN_DLL=1  VK_PROTOTYPES FOLDER ${SIMUL_PLATFORM_FOLDER_PREFIX})

if(SIMUL_SOURCE_BUILD)
target_link_directories(SimulVulkan_MT PUBLIC ${VULKAN_SDK_DIR}/Lib)

if(${CMAKE_SYSTEM_NAME} MATCHES "Windows")
	target_compile_definitions(SimulVulkan_MT PRIVATE  VK_USE_PLATFORM_WIN32_KHR  )
endif()

target_include_directories(SimulVulkan_MT PRIVATE "${VULKAN_SDK_DIR}/Include")
target_include_directories(SimulVulkan_MT PRIVATE "${SIMUL_PLATFORM_DIR}/External/stb")
target_include_directories(SimulVulkan_MT PUBLIC "${SIMUL_PLATFORM_DIR}/Vulkan")
endif()

add_dynamic_library(SimulVulkan SOURCES ${SOURCES} ${HEADERS} FOLDER ${SIMUL_PLATFORM_FOLDER_PREFIX} )

if(SIMUL_SOURCE_BUILD)
target_link_directories(SimulVulkan_MD PUBLIC ${VULKAN_SDK_DIR}/Lib)
target_compile_definitions(SimulVulkan_MD PRIVATE SIMUL_DYNAMIC_LINK=1 SIMUL_VULKAN_DLL=1  VK_PROTOTYPES )

if(${CMAKE_SYSTEM_NAME} MATCHES "Windows")
	target_compile_definitions(SimulVulkan_MD PRIVATE  VK_USE_PLATFORM_WIN32_KHR  )
endif()

target_include_directories(SimulVulkan_MD PRIVATE "${VULKAN_SDK_DIR}/Include")
target_include_directories(SimulVulkan_MD PRIVATE "${SIMUL_PLATFORM_DIR}/External/stb")
target_include_directories(SimulVulkan_MD PUBLIC "${SIMUL_PLATFORM_DIR}/Vulkan")

add_sfx_shader_project( VulkanCoreShaders "${CMAKE_CURRENT_SOURCE_DIR}/GLSL/GLSL.json" INCLUDES "${CMAKE_CURRENT_SOURCE_DIR}/GLSL" "${SIMUL_PLATFORM_DIR}/Shaders/SL" SOURCES ${SHADERS} ${SHADER_INCLUDES} ${SHADER_DEFS} OPTIONS -w OUTPUT "${CMAKE_CURRENT_BINARY_DIR}/shaderbin" FOLDER ${SIMUL_PLATFORM_FOLDER_PREFIX}/Shaders)

if(SIMUL_BUILD_SHADERS)
	#add_dependencies(SimulVulkan_MT VulkanShaders)
	#add_dependencies(SimulVulkan_MD VulkanShaders)
endif()

target_link_libraries(SimulVulkan_MD SimulCrossPlatform_MD SimulMath_MD Core_MD )

if(${CMAKE_SYSTEM_NAME} MATCHES "Windows")
target_link_libraries(SimulVulkan_MD  vulkan-1)
else()
	target_link_directories( SimulVulkan_MD PRIVATE ${VULKAN_SDK_DIR}/x86_64/lib/ /usr/lib/x86_64-linux-gnu )
	target_link_libraries(SimulVulkan_MD libvulkan.so)
endif()
endif()
