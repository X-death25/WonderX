/*
 * ------------------------------------------------------------------------------------------------------------------------
 *
 * \file main.c
 * \brief LibFTDI software for communicate with WonderX Cartridge
 * \author X-death for Yaronet forum (https://www.yaronet.com/topics/189776-projet-cartouche-de-developpement-wonderswan)
 * \date 2018/09
 *
 * ------------------------------------------------------------------------------------------------------------------------
 */

#include <stdio.h>
#include <stdlib.h>
#include <stdarg.h>
#include <string.h>
#include <ctype.h>
#include <time.h>
#include <math.h>

#include <ftdi.h>


// WonderX Special Command

#define WAKEUP  0x10  // WakeUP for first STM32 Communication
#define READ_MD 0x11

// WonderX Specific Variable



int main()
{

  // LibFTDI specific var

    int ret;
    struct ftdi_context *ftdi;
    struct ftdi_version_info version;
    
   // Wonder X Specific Var

   // Main Program   

    printf("\n");
    printf(" ---------------------------------\n");
    printf("    WonderX Flasher Software      \n");
    printf(" ---------------------------------\n");
	printf("\n");

	// Init LibFTDI


    if ((ftdi = ftdi_new()) == 0)
   {
        fprintf(stderr, "ftdi_new failed\n");
        return EXIT_FAILURE;
    }
    version = ftdi_get_library_version();
    printf("Initialized libftdi %s (major: %d, minor: %d, micro: %d, snapshot ver: %s)\n",
    version.version_str, version.major, version.minor, version.micro,
    version.snapshot_str);
    printf("\n");
	
	// Try to open FTDI
  

  		while(1);


   		return 0;

  
}


