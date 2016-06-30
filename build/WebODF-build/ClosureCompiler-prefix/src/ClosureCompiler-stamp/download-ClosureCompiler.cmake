#=============================================================================
# Copyright 2008-2013 Kitware, Inc.
# Copyright 2016 Ruslan Baratov
#
# Distributed under the OSI-approved BSD License (the "License");
# see accompanying file Copyright.txt for details.
#
# This software is distributed WITHOUT ANY WARRANTY; without even the
# implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
# See the License for more information.
#=============================================================================
# (To distribute this file outside of CMake, substitute the full
#  License text for the above reference.)

cmake_minimum_required(VERSION 3.5)

function(check_file_hash has_hash hash_is_good)
  if("${has_hash}" STREQUAL "")
    message(FATAL_ERROR "has_hash Can't be empty")
  endif()

  if("${hash_is_good}" STREQUAL "")
    message(FATAL_ERROR "hash_is_good Can't be empty")
  endif()

  if("MD5" STREQUAL "")
    # No check
    set("${has_hash}" FALSE PARENT_SCOPE)
    set("${hash_is_good}" FALSE PARENT_SCOPE)
    return()
  endif()

  set("${has_hash}" TRUE PARENT_SCOPE)

  message(STATUS "verifying file...
       file='C:/git/ViewerJS/build/WebODF-build/downloads/compiler-20150505.tar.gz'")

  file("MD5" "C:/git/ViewerJS/build/WebODF-build/downloads/compiler-20150505.tar.gz" actual_value)

  if(NOT "${actual_value}" STREQUAL "dea8e282c316316daeb39fcd5708d369")
    set("${hash_is_good}" FALSE PARENT_SCOPE)
    message(STATUS "MD5 hash of
    C:/git/ViewerJS/build/WebODF-build/downloads/compiler-20150505.tar.gz
  does not match expected value
    expected: 'dea8e282c316316daeb39fcd5708d369'
      actual: '${actual_value}'")
  else()
    set("${hash_is_good}" TRUE PARENT_SCOPE)
  endif()
endfunction()

function(sleep_before_download attempt)
  if(attempt EQUAL 0)
    return()
  endif()

  if(attempt EQUAL 1)
    message(STATUS "Retrying...")
    return()
  endif()

  set(sleep_seconds 0)

  if(attempt EQUAL 2)
    set(sleep_seconds 5)
  elseif(attempt EQUAL 3)
    set(sleep_seconds 5)
  elseif(attempt EQUAL 4)
    set(sleep_seconds 15)
  elseif(attempt EQUAL 5)
    set(sleep_seconds 60)
  elseif(attempt EQUAL 6)
    set(sleep_seconds 90)
  elseif(attempt EQUAL 7)
    set(sleep_seconds 300)
  else()
    set(sleep_seconds 1200)
  endif()

  message(STATUS "Retry after ${sleep_seconds} seconds (attempt #${attempt}) ...")

  execute_process(COMMAND "${CMAKE_COMMAND}" -E sleep "${sleep_seconds}")
endfunction()

if("C:/git/ViewerJS/build/WebODF-build/downloads/compiler-20150505.tar.gz" STREQUAL "")
  message(FATAL_ERROR "LOCAL can't be empty")
endif()

if("http://dl.google.com/closure-compiler/compiler-20150505.tar.gz" STREQUAL "")
  message(FATAL_ERROR "REMOTE can't be empty")
endif()

if(EXISTS "C:/git/ViewerJS/build/WebODF-build/downloads/compiler-20150505.tar.gz")
  check_file_hash(has_hash hash_is_good)
  if(has_hash)
    if(hash_is_good)
      message(STATUS "File already exists and hash match (skip download):
  file='C:/git/ViewerJS/build/WebODF-build/downloads/compiler-20150505.tar.gz'
  MD5='dea8e282c316316daeb39fcd5708d369'"
      )
      return()
    else()
      message(STATUS "File already exists but hash mismatch. Removing...")
      file(REMOVE "C:/git/ViewerJS/build/WebODF-build/downloads/compiler-20150505.tar.gz")
    endif()
  else()
    message(STATUS "File already exists but no hash specified (use URL_HASH):
  file='C:/git/ViewerJS/build/WebODF-build/downloads/compiler-20150505.tar.gz'
Old file will be removed and new file downloaded from URL."
    )
    file(REMOVE "C:/git/ViewerJS/build/WebODF-build/downloads/compiler-20150505.tar.gz")
  endif()
endif()

set(retry_number 5)

foreach(i RANGE ${retry_number})
  sleep_before_download(${i})

  message(STATUS "downloading...
       src='http://dl.google.com/closure-compiler/compiler-20150505.tar.gz'
       dst='C:/git/ViewerJS/build/WebODF-build/downloads/compiler-20150505.tar.gz'
       timeout='none'")

  
  

  file(
      DOWNLOAD
      "http://dl.google.com/closure-compiler/compiler-20150505.tar.gz" "C:/git/ViewerJS/build/WebODF-build/downloads/compiler-20150505.tar.gz"
      SHOW_PROGRESS
      # no TIMEOUT
      STATUS status
      LOG log
  )

  list(GET status 0 status_code)
  list(GET status 1 status_string)

  if(status_code EQUAL 0)
    check_file_hash(has_hash hash_is_good)
    if(has_hash AND NOT hash_is_good)
      message(STATUS "Hash mismatch, removing...")
      file(REMOVE "C:/git/ViewerJS/build/WebODF-build/downloads/compiler-20150505.tar.gz")
    else()
      message(STATUS "Downloading... done")
      return()
    endif()
  else()
    message("error: downloading 'http://dl.google.com/closure-compiler/compiler-20150505.tar.gz' failed
  status_code: ${status_code}
  status_string: ${status_string}
  log:
  --- LOG BEGIN ---
  ${log}
  --- LOG END ---"
    )
  endif()
endforeach()

message(FATAL_ERROR "Downloading failed")
