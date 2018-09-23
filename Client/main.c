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
#include <unistd.h>
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

    int ret; // LibFTDI var for return info
    struct ftdi_context *ftdi;
    struct ftdi_version_info version;
    struct ftdi_transfer_control *wr_transfer, *rd_transfer;

    int baudrate = 115200;
    unsigned char tx_buf[128];
    unsigned char rx_buf[128];

    // Wonder X Specific Var

    int i=0;
    int choixMenu=0;

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

    printf("Detecting FTDI Chip...\n");

    // Try to open FTDI with correct id

    if ((ret = ftdi_usb_open(ftdi, 0x0403, 0x6001)) < 0)
    {
        fprintf(stderr, "unable to open ftdi device: %d (%s)\n", ret, ftdi_get_error_string(ftdi));
        ftdi_free(ftdi);
        return EXIT_FAILURE;
    }

    printf("FTDI chip detected sucessfully !\n");

    // Read out FTDIChip-ID of R type chips

    if (ftdi->type == TYPE_R)
    {
        unsigned int chipid;
        printf("FTDI_read_chipid: %d\n", ftdi_read_chipid(ftdi, &chipid));
        printf("FTDI chipid: %X\n", chipid);
    }

// Set baudrate

    if ((ret = ftdi_set_baudrate(ftdi, baudrate)) < 0)
    {
        fprintf(stderr, "unable to set baudrate: %d (%s)\n", ret, ftdi_get_error_string(ftdi));
        exit(-1);
    }
    printf("Baudrate set to 115200\n");

// Set BItbang Mode

    printf("Enabling bitbang mode");
    ftdi_set_bitmode(ftdi, 0xFF, BITMODE_BITBANG);
    // ftdi_set_bitmode(ftdi, 0xFF, BITMODE_RESET); // switch off bitbang mode, back to regular serial/FIFO


// Clean Buffer


    for (i=0; i<128; i++)
    {
        tx_buf[i]=0xAA;
        rx_buf[i]=0x00;
    }

// Display Menu


    printf("\n\n --- MENU ---\n");
    printf(" 1) Write FT245 FIFO \n");
    printf(" 2) Read FT245 FIFO \n");

    printf("\nYour choice: \n");
    scanf("%d", &choixMenu);

    switch(choixMenu)
    {

    case 1: // Write FT245 FIFO

        printf("Writing to the FIFO... \n");
        wr_transfer = ftdi_write_data_submit(ftdi,tx_buf,sizeof(tx_buf));

// Wait for transfers to complete

        if (wr_transfer > 0)
        {
            ftdi_transfer_data_done(wr_transfer);
        }
        if (wr_transfer < 0)
        {
            printf("Write error \n");
            exit(-1);
        }
        printf("FIFO Writted Sucessfully ! \n");
        ftdi_usb_close(ftdi);
        ftdi_free(ftdi);
        break;

    case 2: // Read FT245 FIFO

        printf("\n");
        printf("Reading from the FIFO... \n");
        rd_transfer = ftdi_read_data_submit(ftdi,rx_buf,sizeof(rx_buf));

// Wait for transfers to complete

        if (rd_transfer > 0)
        {
            ftdi_transfer_data_done(rd_transfer);
        }

        if (rd_transfer < 0)
        {
            printf("read error \n");
            exit(-1);
        }

        printf("FIFO Readed Sucessfully ! \n");

// Display FTDI FIFO

        printf("\n");
        printf("Display FIFO value : \n");

        for (i=0; i<128; i++)
        {
            printf("%02X ", rx_buf[i] & 255);
            if (i % 16 == 15 && i < 128)
                printf("\n");
        }
        ftdi_usb_close(ftdi);
        ftdi_free(ftdi);
        break;
    }



    return 0;


}


