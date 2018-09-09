######################################################################################
# CMake directives
######################################################################################

# Nous voulons un cmake "récent" pour utiliser les dernières fonctionnalités
cmake_minimum_required(VERSION 3.0)


######################################################################################
# Project declaration and options
######################################################################################

# Notre projet est étiqueté WonderX
project(WonderX)

# Crée des variables avec les fichiers à compiler
set(SRCS
    main.c
    )

######################################################################################
# CMake
######################################################################################
    
# Notre exécutable
add_executable(WonderX ${SRCS})


######################################################################################
# Dependencies and Definitions
######################################################################################

find_package(PkgConfig REQUIRED)

# On recherche la présence de la lib externe libftdi
find_package(LibFTDI1 NO_MODULE REQUIRED)

# Une fois la dépendance trouvée, nous l'incluons au projet

if (LibFTDI1_FOUND)
message("libftdi found")
set(_includes ${LIBFTDI_INCLUDE_DIRS})
set(_libs ${LIBFTDI_LIBRARIES})
target_include_directories(WonderX PUBLIC ${LIBFTDI_INCLUDE_DIRS}})
target_link_libraries (WonderX ${LIBFTDI_LIBRARIES})
include_directories(WonderX ${LIBFTDI_INCLUDE_DIRS})

else ()
  # Sinon, nous affichons un message d'erreur
  message("libftdi not found please download and install it")

endif ()








