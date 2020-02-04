

find_program(SIMUL_FX_EXECUTABLE fx)


function ( add_sfx_shader_project targetName configJsonFile )
	if(SIMUL_BUILD_SHADERS)
		cmake_parse_arguments(${targetName} "" "INTERMEDIATE;OUTPUT" "INCLUDES;SOURCES;OPTIONS" ${ARGN} )
		set(EXTRA_OPTS${targetName}${targetName})
		foreach(opt_in ${${targetName}_OPTIONS})
			set(EXTRA_OPTS${targetName}${targetName} "${EXTRA_OPTS${targetName}} ${opt_in}" )
		endforeach()
		set(INCLUDE_OPTS)
		foreach(incl_path ${${targetName}_INCLUDES})
			set(INCLUDE_OPTS ${INCLUDE_OPTS} -I"${incl_path}" )
		endforeach()
		if(NOT "${EXTRA_OPTS_S${targetName}}" STREQUAL "")
			string(REPLACE "\"" "" EXTRA_OPTS_S${targetName} ${EXTRA_OPTS${targetName}})
		endif()
		if(SIMUL_DEBUG_SHADERS)
			set(EXTRA_OPTS_S${targetName} ${EXTRA_OPTS_S${targetName}} -v)
		endif()
		#message("add_sfx_shader_project ${targetName} ${configJsonFile}")
		set(srcs_includes)
		set(srcs_shaders)
		set(srcs)
		set(outputs${targetName})
		set(out_folder ${${targetName}_OUTPUT})
		if("${${targetName}_INTERMEDIATE}" STREQUAL "")
			set(intermediate_folder "${CMAKE_CURRENT_BINARY_DIR}/sfx_intermediate")
		else()
			set(intermediate_folder ${${targetName}_INTERMEDIATE})
		endif()
		foreach(in_f ${${targetName}_SOURCES})
			list(APPEND srcs ${in_f})
			string(FIND ${in_f} ".sl" slpos REVERSE)
			if(NOT slpos EQUAL -1)
				list(APPEND srcs_includes ${in_f}) 
			endif()
			string(FIND ${in_f} ".sfx" pos REVERSE)
			if(NOT ${pos} EQUAL -1)
					#message( STATUS "${SIMUL_SFX_EXECUTABLE} ${in_f} -I\"${${targetName}_INCLUDES}\" -O\"${out_folder}\" -P\"${configJsonFile}\" -M\"${intermediate_folder}\" ${EXTRA_OPTS_S${targetName}}" )
				list(APPEND srcs_shaders ${in_f})
				get_filename_component(name ${in_f} NAME )
				string(REPLACE ".sfx" ".sfxo" out_f ${name})
				set(out_f "${out_folder}/${out_f}")
				separate_arguments(EXTRA_OPTS_S${targetName} WINDOWS_COMMAND "${EXTRA_OPTS${targetName}}")
				add_custom_command(OUTPUT ${out_f}
					COMMAND ${SIMUL_SFX_EXECUTABLE} ${in_f} ${INCLUDE_OPTS} -O"${out_folder}" -P"${configJsonFile}" -M"${intermediate_folder}" ${EXTRA_OPTS_S${targetName}}
					MAIN_DEPENDENCY ${in_f}
					WORKING_DIRECTORY ${out_folder}
					DEPENDS ${SIMUL_SFX_EXECUTABLE}
					)
				list(APPEND outputs${targetName} ${out_f})
			else()
				if(MSVC)
					set_source_files_properties( ${in_f} PROPERTIES HEADER_FILE_ONLY ON )
					#message("set_source_files_properties( ${in_f} PROPERTIES HEADER_FILE_ONLY ON )")
				endif()
			endif()
		endforeach()
		source_group("Shaders" FILES  ${srcs_shaders} )
		source_group("Shader Includes" FILES ${srcs_includes} )
		add_custom_target(${targetName} DEPENDS ${outputs${targetName}} SOURCES ${srcs} ${configJsonFile} )
		set_target_properties( ${targetName} PROPERTIES FOLDER Shaders)
		set_target_properties( ${targetName} PROPERTIES EXCLUDE_FROM_ALL FALSE )
		set_target_properties( ${targetName} PROPERTIES EXCLUDE_FROM_DEFAULT_BUILD_DEBUG FALSE )
		set_target_properties( ${targetName} PROPERTIES EXCLUDE_FROM_DEFAULT_BUILD_RELEASE FALSE )
		if(${CMAKE_SYSTEM_NAME} MATCHES "Windows" OR ${CMAKE_SYSTEM_NAME} MATCHES "Linux")
			add_dependencies( ${targetName} Sfx )
		endif()
		set(${out_var} "${outputs${targetName}}" PARENT_SCOPE)
	endif()
endfunction()

function( add_fx_shader_project targetName )
	if(SIMUL_BUILD_SHADERS)
	cmake_parse_arguments(add_fx_shader_project "" "OUTPUT" "INCLUDES;SOURCES;OPTIONS" ${ARGN} )
	set(INCLUDE_OPTS)
	foreach(incl_path ${add_fx_shader_project_INCLUDES})
		set(INCLUDE_OPTS ${INCLUDE_OPTS} /I"${incl_path}" )
	endforeach()
	set(srcs)
	set(outputs${targetName})
	set(FX_OPTIONS)
	if(SIMUL_DEBUG_SHADERS)
		set(FX_OPTIONS /Zi /Od)
	endif()
	#message("add_fx_shader_project(${targetName} )")
	foreach(in_f ${add_fx_shader_project_SOURCES})
		list(APPEND srcs ${in_f})
		string(FIND ${in_f} ".sfx" pos REVERSE)
		if(NOT ${pos} EQUAL -1)
			#message( STATUS "${SIMUL_FX_EXECUTABLE} ${in_f} ${pos}" )
			get_filename_component(name ${in_f} NAME )
			string(REPLACE ".sfx" ".fxo" out_f ${name})
			#file(RELATIVE_PATH out_f ${CMAKE_CURRENT_SOURCE_DIR} ${out_f})
			set(out_f "${add_fx_shader_project_OUTPUT}/${out_f}")
			add_custom_command(OUTPUT ${out_f}
				COMMAND ${SIMUL_FX_EXECUTABLE} ${FX_OPTIONS} /E"main" ${INCLUDE_OPTS} /Fo"${out_f}" /T"fx_5_0" /nologo ${in_f}
				MAIN_DEPENDENCY ${in_f}
				WORKING_DIRECTORY ${out_folder}
				COMMENT "${SIMUL_FX_EXECUTABLE} ${FX_OPTIONS} /E\"main\" /I\"${add_fx_shader_project_INCLUDES}\" /Fo\"${out_f}\" /T fx_5_0 /nologo ${in_f}"
				)
			list(APPEND outputs${targetName} ${out_f})
		else()
			if(MSVC)
				set_source_files_properties( ${in_f} PROPERTIES HEADER_FILE_ONLY TRUE )
			endif()
		endif()
	endforeach()
	add_custom_target(${targetName} DEPENDS ${outputs${targetName}} SOURCES ${srcs})
	set_target_properties( ${targetName} PROPERTIES FOLDER Shaders)
	set_target_properties( ${targetName} PROPERTIES EXCLUDE_FROM_ALL FALSE )
	set_target_properties( ${targetName} PROPERTIES EXCLUDE_FROM_DEFAULT_BUILD_DEBUG FALSE )
	set_target_properties( ${targetName} PROPERTIES EXCLUDE_FROM_DEFAULT_BUILD_RELEASE FALSE )
	set(${out_var} "${outputs${targetName}}" PARENT_SCOPE)
	endif()
endfunction()

find_program(SIMUL_SFX_EXECUTABLE sfx)
