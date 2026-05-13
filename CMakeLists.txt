cmake_minimum_required(VERSION 3.13)

project(codecrafters-http-server C ASM_NASM)

set(BINARY_NAME "http-server")

set(CMAKE_ASM_NASM_OBJECT_FORMAT elf64)
set(CMAKE_ASM_NASM_FLAGS_DEBUG "-g -F dwarf")

set(SOURCES
    src/main.asm
)

add_executable(${BINARY_NAME} ${SOURCES})

set_target_properties(${BINARY_NAME} PROPERTIES LINK_FLAGS "-nostdlib")